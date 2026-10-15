return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "markdown",
          "markdown_inline",
          "diff",
          "java",
          "go",
          "python",
        },
        highlight = { enabled = true },
      })
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "storm",
        on_highlights = function(hl, colors)
          hl["@markup.heading.1.markdown"] = { fg = colors.comment, bold = true }
          hl["@markup.heading.2.markdown"] = { fg = colors.comment, bold = true }
          hl["@markup.heading.3.markdown"] = { fg = colors.comment, bold = true }
          hl["@markup.heading.4.markdown"] = { fg = colors.comment, bold = true }
          hl["@markup.heading.5.markdown"] = { fg = colors.comment, bold = true }
          hl["@markup.heading.6.markdown"] = { fg = colors.comment, bold = true }
          hl.DiffAdd = { bg = "#223e2f", fg = "none" }
          hl.DiffAdded = { fg = "#4ade80", bold = true }
          hl.DiffDelete = { bg = "#441f24", fg = "none" }
          hl.DiffRemoved = { fg = "#f87171", bold = true }
          hl.DiffChange = { bg = "#1c2c42", fg = "none" }
          hl.DiffText = { bg = "#2b4c7e", fg = "none", bold = true }
        end,
      })
      vim.cmd.colorscheme("tokyonight-storm")
    end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
