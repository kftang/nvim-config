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
    basedpyright = {},
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
