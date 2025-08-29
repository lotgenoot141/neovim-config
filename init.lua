--[[ TODO
- folding
- comment folding
	- auto fold all level 1 folds by default
- file navigation
	- oil
	- hover nvim tree should preview file
	- maybe use mini.pick instead of telescope
- make use of new completion functionality (https://youtube.com/watch?v=ZiH59zg59kg)
- configure snake and camel case as words
- configure which key
--]]

do -- options
	-- TODO: highlight current line
	vim.g.mapleader = " "
	vim.g.zig_fmt_autosave = 0

	vim.opt.autoindent = true
	vim.opt.laststatus = 3 -- global status
	vim.opt.number = true
	vim.opt.shiftwidth = 4
	vim.opt.showmode = false
	vim.opt.smartindent = true
	vim.opt.termguicolors = true
	vim.opt.tabstop = 4
	vim.opt.winborder = "single"

	vim.opt.colorcolumn = { 80, 120 }
	vim.opt.expandtab = false
	vim.opt.foldlevel = 99
	vim.opt.foldlevelstart = 99
	vim.opt.relativenumber = true
	vim.opt.scrolloff = 5
	vim.opt.wrap = false
end

do -- plugins
	-- installs plugins in ~/.local/share/nvim/site/pack/core/opt
	vim.pack.add({
		"https://github.com/Saecki/crates.nvim",
		"https://github.com/catppuccin/nvim",
		"https://github.com/hrsh7th/cmp-nvim-lsp",
		"https://github.com/hrsh7th/nvim-cmp",
		"https://github.com/kevinhwang91/nvim-ufo",
		"https://github.com/kevinhwang91/promise-async",
		"https://github.com/lewis6991/gitsigns.nvim",
		"https://github.com/lukas-reineke/indent-blankline.nvim",
		"https://github.com/neovim/nvim-lspconfig",
		"https://github.com/nvim-lua/plenary.nvim",
		"https://github.com/nvim-lualine/lualine.nvim",
		"https://github.com/nvim-telescope/telescope.nvim",
		"https://github.com/nvim-tree/nvim-tree.lua",
		"https://github.com/nvim-tree/nvim-web-devicons",
		"https://github.com/nvim-treesitter/nvim-treesitter",
		"https://github.com/nvim-treesitter/nvim-treesitter-context",
		"https://github.com/windwp/nvim-autopairs",
	})
end

do -- lsp
	-- TODO: how to make this language agnostic?
	vim.lsp.enable({
		"clangd",
		"cssls",
		"lua_ls",
		"nixd",
		"pyright",
		"rust_analyzer",
		"taplo",
		"zls",
	})

	vim.lsp.semantic_tokens.enable(false)
end

do -- colorscheme
	require("catppuccin").setup({
		transparent_background = true,
		float = { transparent = true },
	})
	vim.cmd.colorscheme("catppuccin")
end

do -- completions
	local cmp = require("cmp")
	cmp.setup({
		window = {
			completion = cmp.config.window.bordered({ border = "single" }),
			documentation = cmp.config.window.bordered({ border = "single" })
		},
		mapping = cmp.mapping.preset.insert({
			["<TAB>"] = cmp.mapping.confirm({ select = true })
		}),
		sources = {
			{ name = "nvim_lsp" },
			{ name = "buffer" },
			{ name = "path" },
		}
	})
end

require("telescope").setup() -- for some reason the winborders are rounded instead of square

require("nvim-autopairs").setup()

require("ufo").setup()

require("gitsigns").setup()

require("crates").setup()

require("nvim-web-devicons").setup()

require("treesitter-context").setup({ max_lines = 1 })

-- NOTE: install the tree sitter cli to install parsers on non-nix systems
require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	indent = { enable = true },
})

require("ibl").setup({
	indent = { char = "│" },
	scope = { enabled = false }
})

require("lualine").setup({
	options = {
		component_separators = { left = "", right = "" },
		globalstatus = true,
		refresh = { statusline = 1 },
		section_separators = { left = "", right = "" },
		theme = "auto",
	},
	sections = {
		lualine_a = {
			{
				"mode",
				fmt = function(ident)
					local map = {
						["NORMAL"] = "NOR",
						["INSERT"] = "INS",
						["VISUAL"] = "VIS",
						["V-LINE"] = "V-L",
						["V-BLOCK"] = "V-B",
						["REPLACE"] = "REP",
						["COMMAND"] = "CMD",
						["TERMINAL"] = "TERM",
						["EX"] = "EX",
						["SELECT"] = "SEL",
						["S-LINE"] = "S-L",
						["S-BLOCK"] = "S-B",
						["OPERATOR"] = "OPR",
						["MORE"] = "MORE",
						["CONFIRM"] = "CONF",
						["SHELL"] = "SH",
						["MULTICHAR"] = "MCHR",
						["PROMPT"] = "PRMT",
						["BLOCK"] = "BLK",
						["FUNCTION"] = "FUNC",
					}
					return map[ident] or ident
				end,
			},
		},
		lualine_b = { },
		lualine_c = { "filename" },
		lualine_x = { "diff", "diagnostics" },
		lualine_y = { },
		lualine_z = { "location" },
	},
})

-- removes search highlights after moving the cursor out of the highlighted text
vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("auto-hlsearch", { clear = true }),
	callback = function()
		if vim.v.hlsearch == 1 and vim.fn.searchcount().exact_match == 0 then
			vim.schedule(function()
				vim.cmd.nohlsearch()
			end)
		end
	end
})

-- auto folds imports on file open
--[[
vim.api.nvim_create_autocmd("LspNotify", {
	callback = function(args)
		if args.data.method == "textDocument/didOpen" then
			vim.lsp.foldclose("imports", vim.fn.bufwinid(args.buf))
		end
	end
})
--]]

do -- keybinds
	local function leader_bind(key, action, desc)
		if type(action) == "string" then
			action = "<CMD>" .. action .. "<CR>"
		end
		return {
			mode = "n",
			key = "<LEADER>" .. key,
			action = action,
			options = { desc = desc, silent = true }
		}
	end

	local keybinds = {
		-- you can use lua functions for actions
		leader_bind("b", "Telescope buffers", "List open buffers using Telescope."),
		leader_bind("f", "Telescope find_files", "List files using Telescope."),
		leader_bind("g", "Telescope live_grep", "Live grep files using Telescope."),
		leader_bind("q", "bd", "Deletes the current buffer."),
		leader_bind("h", vim.lsp.buf.hover, "Displays information about symbol under cursor."),
		leader_bind("d", vim.lsp.buf.definition, "Goes to definition of symbol under cursor."),
		leader_bind("a", vim.lsp.buf.code_action, "Lists possible code actions under cursor."),
		-- leader_bind("<TAB>", "NvimTreeToggle", "Toggles the directory tree."),
		leader_bind("i", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, "Toggles inlay hints."),

		-- TODO
		leader_bind("e", vim.diagnostic.open_float, "Show diagnostics."),
		-- Go to next diagnostic
		-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
		-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Next diagnostic" })
		-- Open diagnostics for current line
		-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
	}

	for _, keybind in ipairs(keybinds) do
		vim.keymap.set(keybind.mode, keybind.key, keybind.action, keybind.options)
	end

	vim.api.nvim_create_user_command("Q", "q", {})
	vim.api.nvim_create_user_command("Qa", "qa", {})
	vim.api.nvim_create_user_command("W", "w", {})
	vim.api.nvim_create_user_command("Wq", "wq", {})
	vim.api.nvim_create_user_command("Wa", "wa", {})
	vim.api.nvim_create_user_command("Wqa", "wqa", {})
end

