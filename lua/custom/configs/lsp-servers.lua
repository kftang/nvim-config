local util = require 'lspconfig.util'

return {
  non_mason = {
    -- ccls = {
    --   init_options = {
    --   }
    -- }
    clangd = {}
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
        hostInfo = 'neovim',
        plugins = {
          {
            name = '@vue/typescript-plugin',
            location = '/home/kennyt/.local/lib/node_modules/@vue/typescript-plugin',
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
      on_new_config = function(new_config, new_root_dir)
        if vim.uv.fs_stat(new_root_dir .. '/.venv') then
          new_config.settings.python = { pythonPath = '.venv/bin/python' }
          -- kind of a hack, but include the packages in venv above fcarch/lib for nvregress
          new_config.settings.basedpyright.analysis.extraPaths = {
            '.venv/lib/python3.11/site-packages',
            '.venv/lib/python3.13/site-packages',
            '.venv/lib/python3.14/site-packages',
            '/home/scratch.kennyt_gpu/gpu_t2/hw/nvgpu/fcarch/lib',
          }
        else
          new_config.settings.python = { pythonPath = '/home/utils/Python/builds/3.11.9-20240801/bin/python3.11' }
          new_config.settings.basedpyright.analysis.extraPaths = {
            '/home/scratch.kennyt_gpu/gpu_t2/hw/nvgpu/fcarch/lib',
          }
        end
        new_config.settings.basedpyright.analysis.typeCheckingMode = 'basic'
      end
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
