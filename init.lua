-- folding
	-- TODO: comment folding
	-- TODO: why i cant fold on the last line of a fold?
    -- TODO: auto fold all folds by default
-- TODO: configure renaming/refactoring symbols
-- file navigation
	-- TODO: oil
	-- TODO: hover nvim tree should preview file
-- TODO: make use of new completion functionality (https://youtube.com/watch?v=ZiH59zg59kg)
-- TODO: configure which key
-- TODO: configure snake and camel case as words
-- TODO: check out global default bindings for lsp
-- https://github.com/topics/neovim-colorscheme
-- gpanders.com/blog/whats-new-in-neovim-0-11

do -- options
	--globals
	-- TODO: highlight current line
	vim.g.mapleader = " "
	vim.g.zig_fmt_autosave = 0
	-- givens
	vim.opt.autoindent = true
	vim.opt.laststatus = 3 -- global status
	vim.opt.number = true
	vim.opt.shiftwidth = 4
	vim.opt.showmode = false
	vim.opt.smartindent = true
	vim.opt.termguicolors = true
	vim.opt.tabstop = 4
	vim.opt.winborder = "single"
	-- ambiguous
	vim.opt.colorcolumn = { 80, 120 }
	vim.opt.expandtab = false
	vim.opt.foldlevel = 99
	vim.opt.foldlevelstart = 99
	vim.opt.relativenumber = true
	vim.opt.scrolloff = 5
	vim.opt.wrap = false
end

do -- colorschemes
	require("catppuccin").setup({ transparent_background = true })
	vim.cmd.colorscheme("catppuccin")
end

do -- lsp
	-- TODO: how to make this language agnostic?
	
	local servers = {
		"zls",
		"taplo",
		"rust_analyzer",
		"pyright",
		"nixd",
		"lua_ls",
		"cssls",
		"clangd"
	}

	for _, server in ipairs(servers) do
		require("lspconfig")[server].setup({
			on_attach = function(client, bufnr)
				if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end,
		})
	end
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

-- temp fix (https://github.com/nvim-telescope/telescope.nvim/issues/3436)
require("telescope").setup({ defaults = { border = false } })
require("nvim-autopairs").setup()
require("ufo").setup()
require("gitsigns").setup()
require("crates").setup()
require("nvim-web-devicons").setup()
require("treesitter-context").setup({ max_lines = 1 })
require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	indent = { enable = true },
	parser_install_dir = "/dev/null"
})
require("ibl").setup({
	indent = { char = "│" },
	scope = { enabled = false }
})
--[[
require("nvim-tree").setup({
    auto_reload_on_write = true,
    disable_netrw = true,
    hijack_directories = { auto_open = true, enable = true },
    hijack_netrw = true,
})
--]]

require("oil").setup({
	default_file_explorer = true,
	columns = {
		"icon",
		-- "permissions",
		-- "size",
		-- "mtime"
	},
	delete_to_trash = true,
	constrain_cursor = "name",


	-- Buffer-local options to use for oil buffers
	buf_options = {
		buflisted = false,
		bufhidden = "hide",
	},
	-- Window-local options to use for oil buffers
	win_options = {
		wrap = false,
		signcolumn = "no",
		cursorcolumn = false,
		foldcolumn = "0",
		spell = false,
		list = false,
		conceallevel = 3,
		concealcursor = "nvic",
	},
	-- Selecting a new/moved/renamed file or directory will prompt you to save changes first
	-- (:help prompt_save_on_select_new_entry)
	prompt_save_on_select_new_entry = true,
	-- Oil will automatically delete hidden buffers after this delay
	-- You can set the delay to false to disable cleanup entirely
	-- Note that the cleanup process only starts when none of the oil buffers are currently displayed
	cleanup_delay_ms = 2000,
	lsp_file_methods = {
		-- Enable or disable LSP file operations
		enabled = true,
		-- Time to wait for LSP file operations to complete before skipping
		timeout_ms = 1000,
		-- Set to true to autosave buffers that are updated with LSP willRenameFiles
		-- Set to "unmodified" to only save unmodified buffers
		autosave_changes = false,
	},
	-- Set to true to watch the filesystem for changes and reload oil
	watch_for_changes = false,
	-- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
	-- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
	-- Additionally, if it is a string that matches "actions.<name>",
	-- it will use the mapping at require("oil.actions").<name>
	-- Set to `false` to remove a keymap
	-- See :help oil-actions for a list of all available actions
	keymaps = {
		["g?"] = { "actions.show_help", mode = "n" },
		["<CR>"] = "actions.select",
		["<C-s>"] = { "actions.select", opts = { vertical = true } },
		["<C-h>"] = { "actions.select", opts = { horizontal = true } },
		["<C-t>"] = { "actions.select", opts = { tab = true } },
		["<C-p>"] = "actions.preview",
		["<C-c>"] = { "actions.close", mode = "n" },
		["<C-l>"] = "actions.refresh",
		["-"] = { "actions.parent", mode = "n" },
		["_"] = { "actions.open_cwd", mode = "n" },
		["`"] = { "actions.cd", mode = "n" },
		["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
		["gs"] = { "actions.change_sort", mode = "n" },
		["gx"] = "actions.open_external",
		["g."] = { "actions.toggle_hidden", mode = "n" },
		["g\\"] = { "actions.toggle_trash", mode = "n" },
	},
	-- Set to false to disable all of the above keymaps
	use_default_keymaps = true,
	view_options = {
		-- Show files and directories that start with "."
		show_hidden = false,
		-- This function defines what is considered a "hidden" file
		is_hidden_file = function(name, bufnr)
			local m = name:match("^%.")
			return m ~= nil
		end,
		-- This function defines what will never be shown, even when `show_hidden` is set
		is_always_hidden = function(name, bufnr)
			return false
		end,
		-- Sort file names with numbers in a more intuitive order for humans.
		-- Can be "fast", true, or false. "fast" will turn it off for large directories.
		natural_order = "fast",
		-- Sort file and directory names case insensitive
		case_insensitive = false,
		sort = {
			-- sort order can be "asc" or "desc"
			-- see :help oil-columns to see which columns are sortable
			{ "type", "asc" },
			{ "name", "asc" },
		},
		-- Customize the highlight group for the file name
		highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
			return nil
		end,
	},
	-- Extra arguments to pass to SCP when moving/copying files over SSH
	extra_scp_args = {},
	-- EXPERIMENTAL support for performing file operations with git
	git = {
		-- Return true to automatically git add/mv/rm files
		add = function(path)
			return false
		end,
		mv = function(src_path, dest_path)
			return false
		end,
		rm = function(path)
			return false
		end,
	},
	-- Configuration for the floating window in oil.open_float
	float = {
		-- Padding around the floating window
		padding = 2,
		-- max_width and max_height can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		max_width = 0,
		max_height = 0,
		border = "rounded",
		win_options = {
			winblend = 0,
		},
		-- optionally override the oil buffers window title with custom function: fun(winid: integer): string
		get_win_title = nil,
		-- preview_split: Split direction: "auto", "left", "right", "above", "below".
		preview_split = "auto",
		-- This is the config that will be passed to nvim_open_win.
		-- Change values here to customize the layout
		override = function(conf)
			return conf
		end,
	},
	-- Configuration for the file preview window
	preview_win = {
		-- Whether the preview window is automatically updated when the cursor is moved
		update_on_cursor_moved = true,
		-- How to open the preview window "load"|"scratch"|"fast_scratch"
		preview_method = "fast_scratch",
		-- A function that returns true to disable preview on a file e.g. to avoid lag
		disable_preview = function(filename)
			return false
		end,
		-- Window-local options to use for preview window buffers
		win_options = {},
	},
	-- Configuration for the floating action confirmation window
	confirmation = {
		-- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		-- min_width and max_width can be a single value or a list of mixed integer/float types.
		-- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
		max_width = 0.9,
		-- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
		min_width = { 40, 0.4 },
		-- optionally define an integer/float for the exact width of the preview window
		width = nil,
		-- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		-- min_height and max_height can be a single value or a list of mixed integer/float types.
		-- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
		max_height = 0.9,
		-- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
		min_height = { 5, 0.1 },
		-- optionally define an integer/float for the exact height of the preview window
		height = nil,
		border = "rounded",
		win_options = {
			winblend = 0,
		},
	},
	-- Configuration for the floating progress window
	progress = {
		max_width = 0.9,
		min_width = { 40, 0.4 },
		width = nil,
		max_height = { 10, 0.9 },
		min_height = { 5, 0.1 },
		height = nil,
		border = "rounded",
		minimized_border = "none",
		win_options = {
			winblend = 0,
		},
	},
	-- Configuration for the floating SSH window
	ssh = {
		border = "rounded",
	},
	-- Configuration for the floating keymaps help window
	keymaps_help = {
		border = "rounded",
	},
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
		lualine_b = { "diff", "diagnostics" },
		lualine_c = { "filename" },
		-- lualine_x = { "filetype" },
		-- lualine_y = { "fileformat" },
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

-- auto fold imports on file open
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
		leader_bind("<TAB>", "NvimTreeToggle", "Toggles the directory tree."),
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
