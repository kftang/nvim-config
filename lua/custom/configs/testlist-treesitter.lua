local rtp = vim.fn.stdpath('data') .. '/site'
local testlist = rtp .. '/queries/testlist'
if not vim.uv.fs_stat(testlist) then
    print('Downloading highlight queries for testlist')
    vim.system({'mkdir', '-p', testlist})
    vim.system({
        'curl',
        '-o',
        testlist .. '/highlights.scm',
        'https://gitlab-master.nvidia.com/kennyt/tree-sitter-testlist/-/raw/main/queries/highlights.scm'
    })
end

local parser_config = require 'nvim-treesitter.parsers'.get_parser_configs()
parser_config.testlist = {
    install_info = {
        url = 'https://gitlab-master.nvidia.com/kennyt/tree-sitter-testlist.git', -- local path or git repo
        files = {'src/parser.c'}, -- note that some parsers also require src/scanner.c or src/scanner.cc
        -- optional entries:
        branch = 'main', -- default branch in case of git repo if different from master
        generate_requires_npm = false, -- if stand-alone parser without npm dependencies
        requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
    },
}

vim.filetype.add({
    pattern = {
        ['.*/levels/[^.]*'] = 'testlist'
    },
})
