local util = require 'lspconfig.util'

return {
  non_mason = {
    ccls = {}
  },
  mason = {
    -- clangd = {},
    -- gopls = {},
    -- rust_analyzer = {},
    -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
    --
    -- Some languages (like typescript) have entire language plugins that can be useful:
    --    https://github.com/pmizio/typescript-tools.nvim
    --
    -- But for many setups, the LSP (`tsserver`) will work just fine
    -- tsserver = {},
    --
    -- ruff = {
    --   root_dir = function(fname)
    --     local root_files = {
    --       'pyproject.toml',
    --       'setup.py',
    --       'setup.cfg',
    --       'requirements.txt',
    --       'Pipfile',
    --       '__pycache__',
    --       '__init__.py',
    --     }
    --     return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
    --   end,
    -- },
    -- pylyzer = {
    --   root_dir = function(fname)
    --     local root_files = {
    --       'pyproject.toml',
    --       'setup.py',
    --       'setup.cfg',
    --       'requirements.txt',
    --       'Pipfile',
    --       '__pycache__',
    --       '__init__.py',
    --     }
    --     return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
    --   end,
    -- },
    volar = {},
    ts_ls = {
      init_options = {
        plugins = {
          {
            name = '@vue/typescript-plugin',
            location = '/opt/homebrew/lib/node_modules/@vue/typescript-plugin',
            languages = { 'javascript', 'typescript', 'vue' },
          },
        },
      },
      filetypes = {
        'javascript',
        'typescript',
        'vue',
      },
    },
    basedpyright = {
      root_dir = function(fname)
        -- check if in **/fcarch/scripts, if so the root dir should be cwd
        local script_dir = fname:match('(.*/fcarch/scripts/%w+)/')
        if script_dir ~= nil then
          return script_dir
        end

        local root_files = {
          'pyproject.toml',
          'setup.py',
          'setup.cfg',
          'requirements.txt',
          'Pipfile',
          '__pycache__',
          '__init__.py',
        }
        return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
      end,
      -- TODO: I wanted to configure the lsp with a python environment based on the shebang, but it seems like pyright
      -- doesn't recognize the --pythonPath or --pythonVersion args, and setting it in the config doesn't seem to work either...

      -- on_new_config = function(new_config, new_root_dir)
      --   local python_files = vim.fn.glob('*.py', nil, true)
      --   local grep_cmd = {'grep', '-hoP', '#\\!\\K.*?.*(3(\\.[0-9]+)*)-\\d+'}
      --   for _, file in ipairs(python_files) do
      --     table.insert(grep_cmd, file)
      --   end
      --   vim.system(grep_cmd, {}, function(out)
      --     if out.code ~= 0 then
      --       vim.print(out.stderr)
      --     else
      --       local python_paths = vim.split(out.stdout, '\n', {trimempty=true})
      --       local use_python_path = python_paths[1]
      --       for _, python_path in ipairs(python_paths) do
      --         if python_path ~= use_python_path then
      --           vim.print('Found different shebangs in this directory, please verify if intended...')
      --           vim.print(python_path .. ' vs ' .. use_python_path)
      --         end
      --       end
      --       local python_version = use_python_path:match('3%.%d+')
      --       new_config['settings']['python'] = {pythonPath = use_python_path, pythonVersion = python_version}
      --       vim.print(vim.inspect(new_config))
      --     end
      --   end)
      -- end
    },
    lua_ls = {
      -- cmd = {...},
      -- filetypes = { ...},
      -- capabilities = {},
      settings = {
        Lua = {
          completion = {
            callSnippet = 'Replace',
          },
          -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
          -- diagnostics = { disable = { 'missing-fields' } },
        },
      },
    },
  }
}
