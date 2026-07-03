{
  description = "User's NixOS configuration — laptop + desktop monorepo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # tuxedo landed in nixpkgs-unstable before the NixOS-tested
    # nixos-unstable channel. Keep a small package-only pin until nixos-unstable
    # catches up, then this can be removed and pkgs.tuxedo used directly.
    nixpkgs-tuxedo.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative disk partitioning for the VPS host (server), applied by
    # nixos-anywhere at install time.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative secrets. Plain agenix (not agenix-rekey): each host decrypts
    # with its own SSH host key. Recipient registry is the repo-root secrets.nix;
    # wired in via modules/secrets.nix (server profile only, for now).
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };


    claude-code.url = "github:sadjow/claude-code-nix";

    # MCP server for accurate NixOS/Home Manager/nixpkgs lookups in agents.
    mcp-nixos = {
      url = "github:utensils/mcp-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Oh My Pi CLI binary. Keep this on a versioned release URL so `nswitch`
    # never breaks because GitHub's mutable `latest` asset changed. Update with:
    #   nupdate-omp
    oh-my-pi-bin = {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v16.1.16/omp-linux-x64";
      flake = false;
    };

    # Noctalia v5 — laptop only. Pinned to the currently-installed rev so
    # normal flake updates do not force a Noctalia rebuild on every upstream v5
    # change. Bump this intentionally when you want to update Noctalia v5.
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/6f4dcc539c35cac60b9d15b48b8b537dba55b659";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia greeter — laptop only (greetd greeter). Pinned to a frozen
    # rev like the other Noctalia inputs so `nupdate` does not force a rebuild on
    # every upstream change. Bump intentionally to update the greeter.
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter/1120c4e298590fc550cdd1d03a54fa0705a1e158";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia v4 — the desktop is intentionally pinned to a frozen v4 rev
    # until it is migrated to v5. Pinned to the desktop repo's locked rev.
    noctalia-v4 = {
      url = "github:noctalia-dev/noctalia-shell/da95089dfe5148ee7fb33b3faa314e86de1e6f25";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Noctalia plugins (desktop). Pinned to the desktop repo's locked rev.
    noctalia-plugins = {
      url = "github:noctalia-dev/noctalia-plugins/5274456b9f69304eccbad1264e3fb0a2144f2873";
      flake = false;
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Apple's San Francisco fonts, fetched from Apple's developer site (the
    # license keeps them out of nixpkgs). Used as the shared UI/terminal/Discord
    # font on both hosts: SF Pro for UI/Noctalia/Discord, Nerd-patched SF Mono
    # for the terminal and Noctalia's fixed font.
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Proton-CachyOS (desktop gaming). Follows upstream via flake.lock, so
    # `nupdate` updates it along with the rest of the desktop gaming stack.
    proton-cachyos.url = "github:powerofthe69/proton-cachyos-nix";

    # Steam Deck-like gaming-mode stack for the living-room gaming PC (console).
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS/development";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Eilmeldung is a heavy Rust app. Pin both its source and its nixpkgs so
    # normal switches/updates do not rebuild it unless this pin is bumped.
    eilmeldung-nixpkgs.url = "github:NixOS/nixpkgs/4df1b885d76a54e1aa1a318f8d16fd6005b6401f";
    eilmeldung = {
      url = "github:christo-auer/eilmeldung/de18dd62845ebe78b6920b0938e16af02d5e13eb";
      inputs.nixpkgs.follows = "eilmeldung-nixpkgs";
    };

    # Kopuz music player (laptop/desktop). Intentionally NOT following our nixpkgs:
    # the kopuz.cachix.org binary cache is built against upstream's own pinned
    # nixpkgs, so overriding it would force a heavy Rust/Dioxus rebuild from
    # source and miss the cache.
    kopuz.url = "github:Kopuz-org/kopuz";

  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      claude-code,
      spicetify-nix,
      helium,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      claude-code-pkg = claude-code.packages.${system}.claude-code;
      # Public copy: replace the private Warp fork with a local-compatible terminal shim.
      warp-oss = pkgs.writeShellScriptBin "warp-oss" ''
        exec ${pkgs.kitty}/bin/kitty "$@"
      '';
      eilmeldung-pkg = inputs.eilmeldung.packages.${system}.eilmeldung.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./patches/eilmeldung-plain-article-links.patch ];
      });
      tuxedo-pkg = inputs.nixpkgs-tuxedo.legacyPackages.${system}.tuxedo;
      bumpOhMyPi = pkgs.writeShellApplication {
        name = "bump-oh-my-pi";
        runtimeInputs = with pkgs; [
          curl
          jq
          nix
          python3
        ];
        text = ''
                    set -euo pipefail

                    repo=/etc/nixos
                    asset=omp-linux-x64
                    tag="$(curl -fsSL https://api.github.com/repos/can1357/oh-my-pi/releases/latest | jq -r '.tag_name // empty')"

                    if [ -z "$tag" ]; then
                      echo "could not resolve latest Oh My Pi release tag" >&2
                      exit 1
                    fi

                    url="https://github.com/can1357/oh-my-pi/releases/download/$tag/$asset"
                    python3 - "$repo/flake.nix" "$repo/modules/home.nix" "$tag" "$url" <<'PY'
          import pathlib
          import re
          import sys

          flake_path = pathlib.Path(sys.argv[1])
          module_path = pathlib.Path(sys.argv[2])
          tag = sys.argv[3]
          url = sys.argv[4]
          version = tag.removeprefix("v")

          flake_text = flake_path.read_text()
          flake_pattern = r'https://github\.com/can1357/oh-my-pi/releases/download/[^"]+/omp-linux-x64'
          flake_new, flake_count = re.subn(flake_pattern, url, flake_text, count=1)
          if flake_count != 1:
              sys.exit("expected exactly one versioned oh-my-pi URL in flake.nix")

          module_text = module_path.read_text()
          module_pattern = r'(ohMyPi = pkgs\.stdenvNoCC\.mkDerivation \{\n\s+pname = "oh-my-pi";\n\s+version = ")[^"]+(";)'
          module_new, module_count = re.subn(module_pattern, rf'\g<1>{version}\2', module_text, count=1)
          if module_count != 1:
              sys.exit("expected exactly one ohMyPi version in modules/home.nix")

          if flake_new == flake_text and module_new == module_text:
              print(f"oh-my-pi-bin already points at {url}")
          else:
              flake_path.write_text(flake_new)
              module_path.write_text(module_new)
              print(f"updated oh-my-pi-bin to {url}")
          PY

                    nix flake update oh-my-pi-bin --flake "$repo"
        '';
      };

      # Desktop/laptop profile wiring: the full shared GUI module set (./modules)
      # plus the overlays, Helium NixOS module, and Home Manager that desktops
      # need. Kept here (not a modules/profiles/desktop.nix wrapper) so laptop/desktop
      # evaluate byte-identically to the pre-profile mkHost — both the module list
      # order and importing ./modules directly matter for the derivation hash.
      desktopModules = dir: hostDir: [
        {
          nixpkgs.overlays = [
            helium.overlays.default
            (_final: _prev: { inherit warp-oss; })
          ];
        }
        ./modules
        hostDir
        helium.nixosModules.default

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = {
            claude-code = claude-code-pkg;
            eilmeldung = eilmeldung-pkg;
            tuxedo = tuxedo-pkg;
            oh-my-pi-bin = inputs.oh-my-pi-bin;
          };
          home-manager.users.user.imports = [
            ./modules/home.nix
            (./hosts + "/${dir}/home.nix")
          ];
        }
      ];

      # mkHost keeps these independent things separate:
      #   - the nixosConfigurations.<key> output name (matched by `nh os switch`)
      #   - `dir`         : which hosts/<dir>/ folder supplies host-specific modules
      #   - `hostName`    : the actual networking.hostName set on the system
      #   - `profile`     : "desktop" (laptop/desktop), "gaming-console" (console), or "server" (server)
      #   - `extraModules`: host-only modules (e.g. the Server service for server)
      mkHost =
        {
          dir,
          hostName,
          profile ? "desktop",
          extraModules ? [ ],
        }:
        let
          hostDir = ./hosts + "/${dir}";
        in
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs spicetify-nix;
            claude-code = claude-code-pkg;
            globals = import ./globals.nix;
          };
          modules = [
            { nixpkgs.hostPlatform = system; }
            { networking.hostName = hostName; }
          ]
          ++ (
            if profile == "server" then
              [
                ./modules/profiles/server.nix
                hostDir
              ]
            else if profile == "gaming-console" then
              [
                ./modules/profiles/gaming-console.nix
                inputs.jovian.nixosModules.default
                hostDir
              ]
            else
              desktopModules dir hostDir
          )
          ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        laptop = mkHost {
          dir = "laptop";
          hostName = "laptop";
        };
        desktop = mkHost {
          dir = "desktop";
          hostName = "desktop";
        };
        console = mkHost {
          dir = "console";
          hostName = "console";
          profile = "gaming-console";
        };

        # Example Agent VPS. Server profile (no desktop modules). The Server flake
        # input + service module are added to extraModules in Phase 4.
        server = mkHost {
          dir = "server";
          hostName = "server";
          profile = "server";
        };
      };

      # Public copy exposes the terminal shim used by the desktop modules.
      packages.${system} = {
        inherit warp-oss;
        bump-oh-my-pi = bumpOhMyPi;
      };

      apps.${system}.bump-oh-my-pi = {
        type = "app";
        program = "${bumpOhMyPi}/bin/bump-oh-my-pi";
        meta.description = "Update the pinned Oh My Pi binary input";
      };


      # `nix develop` — Nix tooling for editing this repo. Deliberately NOT wired
      # into `nix flake check`, so an unformatted tree never blocks a build.
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          statix
          deadnix
          nixfmt
        ];
      };
    };
}
