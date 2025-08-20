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
					extraLuaPackages = [];

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
							with lib;
							with pkgs.vimPlugins.nvim-treesitter-parsers;
							with config.neovim.languages;
						lib.flatten [
							(lib.optional c.enable [ c cpp ])
							(lib.optional lua.enable [ lua ])
							(lib.optional markdown.enable [ markdown markdown_inline ])
							(lib.optional nix.enable [ nix ])
							(lib.optional python.enable [ python ])
							(lib.optional rust.enable [ rust ])
							(lib.optional toml.enable [ toml ])
							(lib.optional zig.enable [ zig ])
							# NOTE: other parsers:
							# yaml, xml, wgsl, vimdoc, vim, tmux, sway, sql, ron, regex,
							# latex, json, javascript, javadoc, java, html, go, css, c, asm,
							# typst
						];
					in plugins ++ parsers;
				};

				home.packages =
					with lib;
					with config.neovim.languages;
					with pkgs;
				lib.flatten [
					pkgs.ripgrep
					(optional c.enable clang-tools)
					(optional lua.enable lua-language-server)
					(optional markdown.enable vscode-langservers-extracted)
					(optional nix.enable nixd)
					(optional python.enable pyright)
					(optional rust.enable rust-analyzer)
					(optional toml.enable taplo)
					(optional zig.enable zls)
				];
			};
		};
	};
}

