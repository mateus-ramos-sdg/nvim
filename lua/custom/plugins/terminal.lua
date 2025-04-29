return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      -- Your toggleterm configuration options
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = nil, -- We'll set our own keymaps
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = false,
      terminal_mappings = true,
      persist_size = true,
      direction = 'float', -- Default direction
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = 'curved',
        winblend = 0,
      },
    },
    config = function(_, opts)
      require('toggleterm').setup(opts)

      -- Set up keymappings with alternative prefix
      local map = vim.keymap.set
      local set_keymap_options = { noremap = true, silent = true }

      -- Use <leader>tt as the base prefix
      map('n', '<leader>ttf', function()
        require('toggleterm').toggle(nil, nil, nil, 'float')
      end, vim.tbl_extend('force', set_keymap_options, { desc = 'Toggle floating terminal' }))

      map('n', '<leader>ttv', function()
        require('toggleterm').toggle(nil, nil, nil, 'vertical')
      end, vim.tbl_extend('force', set_keymap_options, { desc = 'Toggle vertical terminal' }))

      map('n', '<leader>tth', function()
        require('toggleterm').toggle(nil, nil, nil, 'horizontal')
      end, vim.tbl_extend('force', set_keymap_options, { desc = 'Toggle horizontal terminal' }))
    end,
  },
}
