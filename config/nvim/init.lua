
-- ===============================
-- 1. Leader Key (Set Early)
-- ===============================

-- ===============================
-- 2. Basic Options
-- ===============================
vim.o.background = "dark"                         -- Dark theme background
vim.opt.number = true                             -- Show absolute line numbers
vim.opt.relativenumber = true                     -- Show relative line numbers
vim.opt.clipboard = "unnamedplus"                 -- Use system clipboard

-- ===============================
-- 3. Syntax Highlighting
-- ===============================
vim.cmd("syntax on")                              -- Enable syntax highlighting

-- ===============================
-- 4. Plugin Manager Setup (lazy.nvim)
-- ===============================
require("lazy").setup({
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Optional: file icons
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
          side = "left",
        },
        filters = {
          dotfiles = false,
        },
      })
    end
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme gruvbox")
    end
  },
  {
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup({
        window = {
          width = 80, -- number of characters across
          options = {
            number = true,
            relativenumber = true,
            wrap = true,
            linebreak = true,
	    scrolloff = 999,
          },
        },
        plugins = {
          options = {
            enabled = true,
            ruler = false,
            showcmd = false,
          },
          twilight = { enabled = true },
        },
      })
    end
  },
  {
    "folke/twilight.nvim",
    config = function()
      require("twilight").setup({
        dimming = {
          alpha = 0.25, -- amount of dimming (0 = no dim, 1 = fully dim)
        },
        context = 1, -- lines around the current line to keep lit
        treesitter = true, -- use Treesitter for smarter dimming
      })
    end
  },
})

-- ===============================
-- 5. Plugin Keybindings
-- ===============================
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>z", ":ZenMode<CR>", { noremap = true, silent = true })

-- ===============================
-- 6. Autocommands
-- ===============================
-- Word count in statusline for .txt and .md files
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "CursorHold", "InsertLeave" }, {
  pattern = { "*.txt", "*.md" },
  callback = function()
    local word_count = vim.fn.wordcount().words
    vim.opt.statusline = "Words: " .. word_count .. " %=%f"
    vim.cmd("redrawstatus")
  end,
})

-- Automatically enter ZenMode for writing files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "markdown", "tex" },
  callback = function()
    vim.defer_fn(function()
      vim.cmd("ZenMode")
    end, 100)
  end,
})

-- Enable spell check for writing files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "markdown", "tex" },
  command = "setlocal spell spelllang=en_gb"
})

-- Auto-save textfiles while editing them.
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = { "*.txt", "*.md", "*.tex" },
  callback = function()
    vim.cmd("silent! write")
  end,
})

-- Auto-open file tree if no file is specified
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.cmd("NvimTreeToggle")
    end
  end,
})

-- ===============================
-- 7. Other Keybindings
-- ===============================
-- Preview markdown with glow
vim.api.nvim_set_keymap('n', '<leader>p', ':!glow %<CR>', { noremap = true, silent = true }) -- Preview markdown
vim.keymap.set('i', '<A-j>', '<Esc>', { noremap = true, silent = true }) -- Remap Alt+J to escape

-- ===========================
-- 8. Edits to the colorscheme
-- ===========================
require("gruvbox").setup({
  overrides = {
    Normal = { bg = "#000000", fg = "#FFFFFF" },
    NormalNC = { bg = "#000000", fg = "#FFFFFF" },  -- inactive splits
  }
})

vim.cmd("colorscheme gruvbox")
