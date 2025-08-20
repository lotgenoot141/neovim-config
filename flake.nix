{
    description = "My Neovim Flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
    };

    outputs = { self, nixpkgs, flake-utils, ... }: {
		homeModules.default = { config, lib, pkgs, ... }: {
			options.neovim = {
				enable = lib.mkEnableOption "Neovim";
				defaultEditor = lib.mkEnableOption "Neovim as the default editor";
				vimAlias = lib.mkEnableOption "Symlink vim to nvim binary";
				languages = {
					c.enable = lib.mkEnableOption "C";
					lua.enable = lib.mkEnableOption "Lua";
					markdown.enable = lib.mkEnableOption "Markdown";
					nix.enable = lib.mkEnableOption "Nix";
					python.enable = lib.mkEnableOption "Python";
					rust.enable = lib.mkEnableOption "Rust";
					toml.enable = lib.mkEnableOption "TOML";
					zig.enable = lib.mkEnableOption "Zig";
					# TODO: other languages
				};
				# TODO: colorschemes
			};

			config = lib.mkIf config.neovim.enable {
				programs.neovim = {
					enable = true;
					defaultEditor = config.neovim.defaultEditor;
					vimAlias = config.neovim.vimAlias;
					extraLuaConfig = builtins.readFile ./init.lua;
					# extraLuaPackages = [];

					plugins = let
						plugins = with pkgs.vimPlugins; [
							catppuccin-nvim
							cmp-nvim-lsp
							crates-nvim
							gitsigns-nvim
							indent-blankline-nvim
							lualine-nvim
							nvim-autopairs
							nvim-cmp
							nvim-lspconfig
							# nvim-tree-lua
							oil-nvim
							nvim-treesitter
							nvim-treesitter-context
							nvim-ufo
							nvim-web-devicons
							telescope-nvim
							cmp-nvim-lsp
							nvim-cmp
						];
						parsers =
							with config.neovim;
							with pkgs.vimPlugins.nvim-treesitter-parsers;
						lib.flatten [
							(lib.optional languages.c.enable [ c cpp ] )
							(lib.optional languages.lua.enable lua)
							(lib.optional languages.markdown.enable [ markdown markdown_inline ])
							(lib.optional languages.nix.enable nix)
							(lib.optional languages.python.enable python)
							(lib.optional languages.rust.enable rust)
							(lib.optional languages.toml.enable toml)
							(lib.optional languages.zig.enable zig)
							# NOTE: other parsers:
							# yaml, xml, wgsl, vimdoc, vim, tmux, sway, sql, ron, regex,
							# latex, json, javascript, javadoc, java, html, go, css, c, asm,
							# typst
						];
					in plugins ++ parsers;
				};

				home.packages =
					with config.neovim;
					with pkgs;
				lib.flatten [
					pkgs.ripgrep
					(lib.optional languages.c.enable clang-tools)
					(lib.optional languages.lua.enable lua-language-server)
					(lib.optional languages.markdown.enable vscode-langservers-extracted)
					(lib.optional languages.nix.enable nixd)
					(lib.optional languages.python.enable pyright)
					(lib.optional languages.rust.enable rust-analyzer)
					(lib.optional languages.toml.enable taplo)
					(lib.optional languages.zig.enable zls)
				];
			};
		};
	};
}

