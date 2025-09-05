{
    description = "My Neovim Flake";

    inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs";

		neovim-nightly-overlay = {
			url = "github:nix-community/neovim-nightly-overlay";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

    outputs = inputs: {
		homeModules.default = { config, lib, pkgs, ... }: {
			options.neovim = {
				enable = lib.mkEnableOption "Neovim";
				defaultEditor = lib.mkEnableOption "Neovim as the default editor";
				vimAlias = lib.mkEnableOption "Symlink vim to nvim binary";
				languages = {
					c.enable = lib.mkEnableOption "C";
					css.enable = lib.mkEnableOption "CSS";
					html.enable = lib.mkEnableOption "HTML";
					java.enable = lib.mkEnableOption "Java";
					javascript.enable = lib.mkEnableOption "JavaScript";
					json.enable = lib.mkEnableOption "JSON";
					lua.enable = lib.mkEnableOption "Lua";
					markdown.enable = lib.mkEnableOption "Markdown";
					nix.enable = lib.mkEnableOption "Nix";
					python.enable = lib.mkEnableOption "Python";
					rust.enable = lib.mkEnableOption "Rust";
					toml.enable = lib.mkEnableOption "TOML";
					typst.enable = lib.mkEnableOption "Typst";
					zig.enable = lib.mkEnableOption "Zig";
				};
			};

			config = lib.mkIf config.neovim.enable {
				programs.neovim = {
					enable = true;
					defaultEditor = config.neovim.defaultEditor;
					vimAlias = config.neovim.vimAlias;
					extraLuaConfig = lib.readFile ./init.lua;
					package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
					plugins = with config.neovim; with pkgs.vimPlugins.nvim-treesitter-parsers; lib.flatten [
						comment
						vim
						vimdoc

						(lib.optional languages.c.enable [ c cpp ])
						(lib.optional languages.css.enable css)
						(lib.optional languages.html.enable html)
						(lib.optional languages.java.enable [ java javadoc ])
						(lib.optional languages.javascript.enable [ javascript jsdoc tsx typescript ])
						(lib.optional languages.json.enable [ json json5 jsonc ])
						(lib.optional languages.lua.enable lua)
						(lib.optional languages.markdown.enable [ markdown markdown_inline ])
						(lib.optional languages.nix.enable nix)
						(lib.optional languages.python.enable python)
						(lib.optional languages.rust.enable [ rust ron ])
						(lib.optional languages.toml.enable toml)
						(lib.optional languages.typst.enable typst)
						(lib.optional languages.zig.enable [ zig zon ])
						# asm, go, latex, regex, ron, sql, sway, tmux, wgsl, xml, yaml,
					];
				};

				home.packages = with config.neovim; with pkgs; lib.flatten [
					pkgs.ripgrep
					pkgs.fd
					(lib.optional languages.c.enable clang-tools)
					(lib.optional languages.lua.enable lua-language-server)
					(lib.optional languages.markdown.enable vscode-langservers-extracted)
					(lib.optional languages.nix.enable nixd)
					(lib.optional languages.python.enable pyright)
					(lib.optional languages.rust.enable rust-analyzer)
					(lib.optional languages.toml.enable taplo)
					(lib.optional languages.typst.enable tinymist)
					(lib.optional languages.zig.enable zls)
				];
			};
		};
	};
}

