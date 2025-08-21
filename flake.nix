{
    description = "My Neovim Flake";

    inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs";
		neovim-nightly-overlay = {
			url = "github:nix-community/neovim-nightly-overlay";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

    outputs = inputs @ { ... }: {
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
				};
			};

			config = lib.mkIf config.neovim.enable {
				programs.neovim = {
					enable = true;
					defaultEditor = config.neovim.defaultEditor;
					vimAlias = config.neovim.vimAlias;
					extraLuaConfig = builtins.readFile ./init.lua;
					package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
				};

				home.packages = with config.neovim; with pkgs; lib.flatten [
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

