local util = require 'lspconfig.util'

return {
  non_mason = {
    clangd = {}
  },
  mason = {
    -- rust_analyzer = {},
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
    vtsls = {
      settings = {
        vtsls = {
          tsserver = {
            globalPlugins = {
              {
                name = '@vue/typescript-plugin',
                location = vim.fn.expand '$MASON/packages' .. '/vue-language-server' .. '/node_modules/@vue/language-server',
                languages = { 'vue' },
                configNamespace = 'typescript',
              },
            },
          },
        },
      },
      filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    },
    vue_ls = {},
    basedpyright = {
      root_dir = function(buf, on_dir)
        local fname = vim.api.nvim_buf_get_name(buf)
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
        local git_root = vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
        local root_dir = util.root_pattern(unpack(root_files))(fname) or git_root
        on_dir(root_dir)
      end,
      before_init = function(_, new_config)
        local new_root_dir = new_config.root_dir
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
