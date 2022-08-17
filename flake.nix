{
  description = "Reproduce neovim config regression";

  outputs = { self, nixpkgs }: {
    actualConfig =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        inherit (pkgs.neovimUtils) makeNeovimConfig;
      in makeNeovimConfig {
        plugins = [
          { plugin = "irrelevant"; config = "foo"; }
          { plugin = "irrelevant"; config = "bar"; }
        ];
      };

    packages.x86_64-linux = {
      expected = nixpkgs.legacyPackages.x86_64-linux.writeTextFile {
        name = "init.vim";
        text = ''
          foo
          bar
        '';
      };

      actual =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          inherit (pkgs.neovimUtils) makeNeovimConfig;
          neovimConfig = makeNeovimConfig {
            plugins = [
              { plugin = "irrelevant"; config = "foo"; }
              { plugin = "irrelevant"; config = "bar"; }
            ];
          };
        in pkgs.writeTextFile {
          name = "init.vim";
          text = neovimConfig.neovimRcContent;
        };
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.actual;
    };
  }
