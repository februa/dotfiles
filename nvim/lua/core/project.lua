-- プロジェクト検出（npm_root 等）
-- toggleterm.lua 等から vim.b.npm_root で参照される

vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = {'*.ts', '*.tsx', '*.js', '*.jsx', '*.json'},
  callback = function(ev)
    local root = vim.fs.root(ev.buf, {'package.json'})
    if root then
      vim.b[ev.buf].npm_root = root
      if vim.uv.fs_stat(root .. '/package-lock.json') then
        vim.b[ev.buf].npm_project = true
      end
    end
  end,
})
