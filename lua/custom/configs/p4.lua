local bit = require("bit")

-- autocmds for p4
vim.api.nvim_create_augroup('p4', {})
vim.api.nvim_create_autocmd('BufReadPost', {
  group = 'p4',
  desc = 'Check if file is in depot',
  callback = function(data)
    local file = data.file
    vim.system({'p4', '-ztag', '-Mj', 'have', file}, { text = true, timeout = 1000 }, function(result)
      vim.b.p4 = false
      if result.code == 0 then
        local result_json = vim.json.decode(result.stdout)
        if result_json.depotFile then
          vim.b.p4 = true
          vim.b.p4_path = result_json.depotFile
          vim.schedule(function()
            -- add keymap to copy depot path
            vim.keymap.set('n', '<leader>cd', function()
              -- copy to unnamed (for using p) and *
              vim.fn.setreg('"', result_json.depotFile)
              vim.fn.setreg('*', result_json.depotFile)
            end, { noremap = true, silent = true, buffer = data.buf })
          end)
        end
      end
    end)
  end
})

vim.api.nvim_create_autocmd('FileChangedRO', {
  group = 'p4',
  desc = 'Add +w permission on change',
  callback = function(data)
    if not vim.b.p4 then
      return
    end

    local file = data.file

    -- get current permissions ( & by 777o to only get the permission bits)
    local perms = bit.band(vim.uv.fs_stat(file).mode, tonumber(777, 8))
    vim.b.orig_perms = perms

    -- add ug+w permissions
    vim.uv.fs_chmod(data.file, bit.bor(perms, tonumber(220, 8)))
    -- refresh file
    vim.cmd('edit!')
    vim.print('Adding +w to file, this file will be opened for edit in p4 upon :w')
    local bufnr = data.buf

    -- add autocmd to run p4 edit when saving
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = 'p4',
      desc = 'Run p4 edit on :w',
      buffer = bufnr,
      callback = function()
        local run = vim.system({'p4', 'edit', file}, {})
        local result = run:wait(10000)
        if result.code ~= 0 then
          vim.print('WARNING: unable to run p4 edit, make sure to either rerun p4 edit or fix the permission bits')
          vim.print(result.stderr)
        else
          vim.print(result.stdout)
          -- clear restore permission autocmd
          vim.api.nvim_clear_autocmds({
            buffer = bufnr,
            group = 'p4',
          })
        end
      end,
    })

    -- add autocmd to restore permissions if not saving
    vim.api.nvim_create_autocmd('BufUnload', {
      group = 'p4',
      desc = 'Restore file permissions if not saving buffer that was RO and in the depot',
      buffer = bufnr,
      callback = function(restore_data)
        vim.print('Restoring file to [RO]')
        vim.uv.fs_chmod(restore_data.file, vim.b[restore_data.buf].orig_perms)
        -- clear restore permission autocmd
        vim.api.nvim_clear_autocmds({
          buffer = bufnr,
          group = 'p4',
        })
      end,
    })
  end,
})

-- p4 commands
vim.api.nvim_create_user_command('P4edit', '!p4 edit %', {})
vim.api.nvim_create_user_command('P4diff', function()
  local file_path = vim.fn.expand('%')
  local temp_buffer = vim.api.nvim_create_buf(false, true)
  vim.system({'p4', 'print', file_path}, {}, function(out)
    if out.code ~= 0 then
      vim.print(out.stderr)
    else
      vim.schedule(function()
        -- turn on diff mode for the current opened file
        vim.cmd('difft')

        local lines = vim.split(out.stdout, "\n")
        -- the first line of p4 print contains the last revision of the file,
        -- use this to set the name of the scratch buffer
        local file_info = table.remove(lines, 1)
        local start, _ = string.find(file_info, ' - ')
        file_info = string.sub(file_info, 1, start)
        vim.api.nvim_buf_set_name(temp_buffer, file_info)

        -- set the contents of the scratch buffer to the latest version of the file in the depot
        vim.api.nvim_buf_set_lines(temp_buffer, 0, 0, true, lines)
        -- open scratch buffer in vsplit
        local split_win = vim.api.nvim_open_win(temp_buffer, false, { vertical = true })
        -- set scratchpad to diff mode and unmodifiable
        vim.api.nvim_win_call(split_win, function()
          vim.cmd('difft')
          vim.cmd('set nomodifiable')
        end)
      end)
    end
  end)
end, {})

vim.api.nvim_create_user_command('P4revert', '!p4 revert %', {})
vim.api.nvim_create_user_command('P4change', function(opts)
  local last_buffer = vim.api.nvim_get_current_buf()
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buffer)
  -- add changespec to buffer
  vim.cmd('read !p4 change -o ' .. opts.args)

  -- use tabs in changespec
  vim.bo[buffer].expandtab = false

  -- create command for saving change
  vim.api.nvim_buf_create_user_command(buffer, 'SaveChange', function()
    local change_spec = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
    vim.api.nvim_win_set_buf(0, last_buffer)
    vim.print('Saving changelist, please wait...')
    vim.system({'p4', 'change', '-i'}, { stdin = change_spec }, function(out)
      if out.code ~= 0 then
        vim.print(out.stderr .. '\nFix the change spec and run :SaveChange again')
        vim.api.nvim_win_set_buf(0, buffer)
      else
        vim.print(out.stdout)
        -- delete scratch buffer
        vim.schedule(function()
          vim.api.nvim_buf_delete(buffer, {})
        end)
      end
    end)
  end, {})

  -- create command for submitting change
  vim.api.nvim_buf_create_user_command(buffer, 'SubmitChange', function()
    local change_spec = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
    vim.api.nvim_win_set_buf(0, last_buffer)
    vim.print('Submitting changelist, please wait...')
    vim.system({'p4', 'submit', '-i'}, { stdin = change_spec }, function(out)
      if out.code ~= 0 then
        vim.print(out.stderr .. '\nFix the change spec and run :SubmitChange again')
        vim.api.nvim_win_set_buf(0, buffer)
      else
        vim.print(out.stdout)
        -- delete scratch buffer
        vim.schedule(function()
          vim.api.nvim_buf_delete(buffer, {})
        end)
      end
    end)
  end, {})

  -- create command for shelving change
  vim.api.nvim_buf_create_user_command(buffer, 'ShelveChange', function()
    local change_spec = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)
    vim.api.nvim_win_set_buf(0, last_buffer)
    vim.print('Shelving changelist, please wait...')
    vim.system({'p4', 'shelve', '-i'}, { stdin = change_spec }, function(out)
      if out.code ~= 0 then
        vim.print(out.stderr .. '\nFix the change spec and run :ShelveChange again')
        vim.api.nvim_win_set_buf(0, buffer)
      else
        vim.print(out.stdout)
        -- delete scratch buffer
        vim.schedule(function()
          vim.api.nvim_buf_delete(buffer, {})
        end)
      end
    end)
  end, {})
end, {})

vim.api.nvim_create_user_command('P4opened', function(opts)
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, buffer)
  -- add changespec to buffer
  vim.cmd('read !p4 opened ' .. opts.args)

  -- use tabs
  vim.bo[buffer].expandtab = false

end, {})

-- p4 aliases
vim.api.nvim_create_user_command('Pe', 'P4edit', {})
vim.api.nvim_create_user_command('Pr', 'P4revert', {})
vim.api.nvim_create_user_command('Pc', 'P4change', {})
vim.api.nvim_create_user_command('Po', 'P4opened', {})

return false
