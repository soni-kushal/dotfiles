-- soni-kushal: my neovim settings
-- (slightly modified kickstart init file)
-- (with additional plugins and options for enhancing writing workflow)

-- ----------------
-- [[ Leader Key ]]
-- ----------------

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- -------------------
-- [[ Font Settings ]]
-- -------------------

vim.g.have_nerd_font = true

-- ---------------------
-- [[ Setting options ]]
-- ---------------------

vim.o.number = true -- set relativenumber instead if you can't do basic maths
vim.o.mouse = "a" -- enables mouse mode, useful for resizing splits, etc.
vim.o.showmode = false -- don't show mode, already in status line
vim.o.clipboard = "unnamedplus"
vim.o.wrap = true
vim.o.linebreak = true
vim.o.breakindent = true -- wrapped lines have same indentation as original
vim.o.undofile = true -- save undo history
vim.o.ignorecase = true -- case insensitive searching
vim.o.smartcase = true -- unless \C or one or more capital letters in search term
vim.o.signcolumn = "yes" -- keep signcolumn on by default
vim.o.updatetime = 250 -- decrease update time
vim.o.timeoutlen = 300 -- decrease mapped sequence wait time
vim.o.splitright = true -- configure how new splits should be opened
vim.o.splitbelow = true
vim.o.laststatus = 2
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.o.list = true -- set how whitespace characters show
vim.opt.listchars = { tab = "⇥ ", trail = "·", nbsp = "␣" }
vim.o.inccommand = "split" -- preview substitutions live, as you type
vim.o.cursorline = true -- show which line your cursor is on
vim.o.scrolloff = 10 -- min number of lines to keep above/below the cursor
vim.o.confirm = true -- confirmation when things would fail because of unsaved changes
vim.o.hidden = true -- allows unsaved file to sit in buffer

-- -------------------
-- [[ Basic Keymaps ]]
-- -------------------

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
-- Exit terminal mode in the builtin terminal with a shortcut
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
-- Keybinds to make split navigation easier.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- ------------------------
-- [[ Basic Autocommands ]]
-- ------------------------

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- ----------------------------------------
-- [[ Install `lazy.nvim` plugin manager ]]
-- ----------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- ---------------------
-- [[ Install plugins ]]
-- ---------------------

require("lazy").setup({

	{
		"NMAC427/guess-indent.nvim",
		config = function()
			require("guess-indent").setup({})
		end,
	},

	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	{ -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VimEnter", -- Sets the loading event to 'VimEnter'
		opts = {
			delay = 0,
			icons = {
				mappings = true,
				keys = {},
			},

			-- Document existing key chains
			spec = {
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		},
	},

	{ -- nvim-tree file explorer
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("nvim-tree").setup({
				view = {
					width = 30,
					side = "left",
				},
				filters = {
					dotfiles = true,
				},
			})
		end,
	},

	{ -- zen mode for focused writing
		"folke/zen-mode.nvim",
		config = function()
			require("zen-mode").setup({
				window = {
					width = 80,
					options = {
						number = true,
						wrap = true,
						linebreak = true,
					},
				},
				plugins = {
					twilight = { enabled = false },
				},
			})
		end,
	},

	{ -- For rendering markdown
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
		opts = {},
	},

	{ -- twilight for dimming unfocused text
		"folke/twilight.nvim",
		config = function()
			require("twilight").setup({
				dimming = {
					alpha = 0.25,
				},
				context = 1,
				treesitter = true,
			})
		end,
	},

	{ -- R Integration Plugin (nvim-R)
		"jalvesaq/Nvim-R",
		config = function() end,
	},

	{ -- UFO for line folding
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			vim.o.foldenable = true
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			require("ufo").setup()
		end,
	},

	{ -- Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",

				build = "make",

				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			-- See `:help telescope.builtin`
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			-- Slightly advanced example of overriding default behavior and theme
			vim.keymap.set("n", "<leader>/", function()
				-- You can pass additional configuration to Telescope to change the theme, layout, etc.
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			-- Shortcut for searching your Neovim configuration files
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- LSP Plugins
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		-- Main LSP Configuration
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by blink.cmp
			"saghen/blink.cmp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
					map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
					map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
					map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")
					---@param client vim.lsp.Client
					---@param method vim.lsp.protocol.Method
					---@param bufnr? integer some lsp support methods only in specific files
					---@return boolean
					local function client_supports_method(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
					end
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if
						client
						and client_supports_method(
							client,
							vim.lsp.protocol.Methods.textDocument_documentHighlight,
							event.buf
						)
					then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if
						client
						and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
					then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = " ",
						[vim.diagnostic.severity.HINT] = " ",
					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						local diagnostic_message = {
							[vim.diagnostic.severity.ERROR] = diagnostic.message,
							[vim.diagnostic.severity.WARN] = diagnostic.message,
							[vim.diagnostic.severity.INFO] = diagnostic.message,
							[vim.diagnostic.severity.HINT] = diagnostic.message,
						}
						return diagnostic_message[diagnostic.severity]
					end,
				},
			})
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
				texlab = {},
			}
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
				"texlab",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
				automatic_installation = false,
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
			},
		},
	},

	{ -- Autocompletion
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			-- Snippet Engine
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {},
				opts = {},
			},
			"folke/lazydev.nvim",
		},
		opts = {
			keymap = {
				preset = "default",
			},

			appearance = {
				nerd_font_variant = "mono",
			},

			completion = {
				documentation = { auto_show = false, auto_show_delay_ms = 500 },
			},

			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = {
					lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},

			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
			signature = { enabled = true },
		},
	},

	{ -- Highlight todo, notes, etc in comments.
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{ -- vimtex for latex compiling and navigation
		"lervag/vimtex",
		lazy = false,
		init = function()
			vim.g.vimtex_view_method = "zathura"
		end,
	},

	-- Inside your require("lazy").setup({ ... }) block
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local function word_count()
				local ft = vim.bo.filetype
				if ft == "markdown" or ft == "text" or ft == "tex" then
					local wc = vim.fn.wordcount()
					return " " .. tostring(wc["words"])
				end
				return ""
			end
			require("lualine").setup({
				options = {
					icons_enabled = true,
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = { statusline = {}, winbar = {} },
					ignore_focus = {},
					always_last_status = true,
					padding = 1,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "encoding", "fileformat", "filetype", word_count },
					lualine_y = { "progress", "location" },
					lualine_z = {
						function()
							return " " .. os.date("%H:%M")
						end,
					},
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				extensions = {},
			})
		end,
	},
	{ -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter", -- Sets main module to use for opts
		-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			-- Autoinstall languages that are not installed
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
	},

	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },

	{ "rebelot/kanagawa.nvim", name = "kanagawa", priority = 1000 },

	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				on_highlights = function(hl, c)
					hl["@markup.heading.1.markdown"] = { fg = c.blue, bold = true }
					hl["@markup.heading.2.markdown"] = { fg = c.green, bold = true }
					hl["@markup.heading.3.markdown"] = { fg = c.yellow, bold = true }
					hl["@markup.heading.4.markdown"] = { fg = c.purple, bold = true }
					hl["@markup.heading.5.markdown"] = { fg = c.red, bold = true }
					hl["@markup.heading.6.markdown"] = { fg = c.cyan, bold = true }
				end,
			})
			vim.cmd("colorscheme tokyonight-night")
			vim.api.nvim_set_hl(0, "markdownH1", { fg = "#7aa2f7", bold = true })
			vim.api.nvim_set_hl(0, "markdownH2", { fg = "#9ece6a", bold = true })
			vim.api.nvim_set_hl(0, "markdownH3", { fg = "#e0af68", bold = true })
			vim.api.nvim_set_hl(0, "markdownH4", { fg = "#bb9af7", bold = true })
			vim.api.nvim_set_hl(0, "markdownH5", { fg = "#f7768e", bold = true })
			vim.api.nvim_set_hl(0, "markdownH6", { fg = "#7dcfff", bold = true })
		end,
	},
})

-- ------------------------
-- [[Custom autocommands ]]
-- ------------------------

-- to turn-on spell check each time a txt, md, or tex file is opened
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "markdown", "tex" },
	callback = function()
		vim.opt.spell = true
		vim.opt.spelllang = "en_gb"
	end,
})

-- ---------------------------
-- [[ Plugin Configurations ]]
-- ---------------------------

-- Configurations for the vimtex plugin
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_method = "latexmk"

-- -------------------------
-- [[ Render Markdown Configuration ]]
-- -------------------------
require("render-markdown").setup({
	-- Render markdown in a split or floating window when opening markdown files
	default = {
		preview = true, -- Enable automatic rendering of the markdown preview
		float = true, -- Open the rendered markdown in a floating window
		syntax = true, -- Enable syntax highlighting using treesitter
		wrap = true, -- Enable line wrapping in the preview
	},

	-- Configure floating window (only relevant if `float = true`)
	float_opts = {
		border = "rounded", -- You can also use 'single', 'double', 'solid', 'none'
		width = 80, -- Width of the floating window (adjust as needed)
		height = 30, -- Height of the floating window (adjust as needed)
		winblend = 10, -- Background transparency for the floating window
		col = "center", -- Horizontal positioning of the window
		row = "center", -- Vertical positioning of the window
	},

	-- Enable automatic Markdown rendering when opening a markdown file
	auto_open = true, -- If true, opens preview automatically when opening a markdown file
})

-- --------------------
-- [[ Other Keybinds ]]
-- --------------------

-- remap Alt+; to esc, for quicker switch to normal mode
vim.api.nvim_set_keymap("i", "<A-;>", "<Esc>", { noremap = true })
-- set leader and e to toggle file-explorer
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
-- set leader and z to toggle zen-mode
vim.keymap.set("n", "<leader>z", ":ZenMode<CR>", { noremap = true, silent = true })
-- set leader and l to toggle twilight
vim.keymap.set("n", "<leader>l", ":Twilight<CR>", { noremap = true, silent = true })

-- Toggle between Day (Kanagawa Lotus) and Night (Tokyonight)
vim.keymap.set("n", "<leader>c", function()
	if vim.g.colors_name == "tokyonight-night" then
		vim.cmd("colorscheme kanagawa-lotus")
		if fidget then
			require("fidget").notify("Switching to Day mode")
		end
	else
		vim.cmd("colorscheme tokyonight-night")
		if fidget then
			require("fidget").notify("Switching to Night mode")
		end
	end
end, { desc = "[C]olorscheme Toggle" })
