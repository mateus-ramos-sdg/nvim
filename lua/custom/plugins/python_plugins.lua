return {
  {
    'brendalf/poetry.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim', 'linux-cultist/venv-selector.nvim' },
    config = function()
      require('poetry').setup()
    end,
    keys = {
      {
        '<Leader>p',
        '<cmd>PoetryEnvList<CR>',
        desc = 'List poetry environments',
      },
    },
  },
}
