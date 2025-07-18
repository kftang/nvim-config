-- autocmds for p4
vim.api.nvim_create_augroup('p4', {})
vim.api.nvim_create_autocmd('BufReadPost', {
  group = 'p4',
  desc = 'Check if file is in depot to prompt to edit file',
  callback = function(data)
    local file = data.file
    vim.system({'p4', '-ztag', '-Mj', 'have', file}, { text = true, timeout = 1000 }, function(result)
      vim.b.p4 = false
      if result.code == 0 then
        local result_json = vim.json.decode(result.stdout)
        if result_json.depotFile then
          vim.b.p4 = true
          vim.b.p4_path = result_json.depotFile
        end
      end
    end)
  end
})

vim.api.nvim_create_autocmd('FileChangedRO', {
  group = 'p4',
  desc = 'p4 edit prompt',
  callback = function(data)
    if not vim.b.p4 then
      return
    end
    local file = data.file
    vim.ui.input({ prompt = 'Open ' .. file .. ' for edit in p4? [y]/n:', default = 'y' }, function(input)
      if input ~= 'y' then
        return
      end
      local run = vim.system({'p4', 'edit', file}, {})
      local result = run:wait(10000)
      if result.code ~= 0 then
        vim.print(result.stderr)
      else
        vim.print(result.stdout)
        vim.cmd('edit!')
      end
    end)
  end,
})

-- p4 commands
vim.api.nvim_create_user_command('P4edit', '!p4 edit %', {})
vim.api.nvim_create_user_command('P4diff', function()
  local file_path = vim.fn.expand('%')
  local temp_file = vim.fn.tempname()
  vim.system({'p4', '-q', 'print', file_path}, {}, function(out)
    if out.code ~= 0 then
      vim.print(out.stderr)
    else
      vim.schedule(function()
        vim.fn.writefile(vim.split(out.stdout, "\n"), temp_file)
        vim.cmd('diffs ' .. temp_file)
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
  local last_buffer = vim.api.nvim_get_current_buf()
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
