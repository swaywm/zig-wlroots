{
  description = "zig-wlroots devel";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; };

  outputs = { self, nixpkgs, ... }:
    let
      pkgsFor = system:
        import nixpkgs {
          inherit system;
          overlays = [ ];
        };

      targetSystems = [ "aarch64-linux" "x86_64-linux" ];
    in {
      devShells = nixpkgs.lib.genAttrs targetSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.mkShell {
            name = "zig-wlroots-devel";
            nativeBuildInputs = with pkgs; [
              zig
              libxkbcommon
              pixman
              stdenv
              wlroots
              wayland
              wayland-protocols
              pkg-config
              wayland-scanner
              zls
            ];
          };
        });
    };
}
