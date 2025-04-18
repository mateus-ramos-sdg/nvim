-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = {
          "nvim-treesitter/nvim-treesitter",
          "nvim-tree/nvim-web-devicons", -- or 'echasnovski/mini.icons' if you prefer
        },
        config = function()
          require("render-markdown").setup({
            -- Optional: specify file types to enable rendering
            file_types = { "markdown", "quarto" },
          })
        end,
        ft = { "markdown", "quarto" }, -- Lazy-load on these file types
      }
}
