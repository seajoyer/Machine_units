{
  description = "Machine_units project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        cppProject = pkgs.clangStdenv.mkDerivation {
          name = "Machine_units";
          src = ./.;

          nativeBuildInputs = with pkgs; [ gnumake libgcc ];

          buildInputs = with pkgs; [ eigen ];

          EIGEN_PATH = "${pkgs.eigen}/include/eigen3";

          buildPhase = ''
            make -j $($NIX_BUILD_CORES)
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp build/Machine_units $out/bin/
          '';
        };

        pythonEnv = pkgs.python3.withPackages (ps: with ps; [ numpy ]);

        pythonProject = pkgs.stdenv.mkDerivation {
          pname = "machine_units";
          version = "0.1.0";
          name = "machine_units-0.1.0";

          src = ./py;

          nativeBuildInputs = [ pythonEnv ];

          installPhase = ''
            mkdir -p $out/bin $out/lib/python
            cp -r . $out/lib/python/
            cat > $out/bin/run-python <<EOF
            #!${pythonEnv}/bin/python
            import sys
            import os

            sys.path.insert(0, '$out/lib/python')

            import main
            main.main()
            EOF
            chmod +x $out/bin/run-python
          '';
        };

      in {
        packages = {
          cpp = cppProject;
          py = pythonProject;
          default = cppProject;
        };

        apps = {
          cpp = flake-utils.lib.mkApp { drv = cppProject; };
          py = flake-utils.lib.mkApp {
            drv = pythonProject;
            name = "run-python";
          };
          default = flake-utils.lib.mkApp { drv = cppProject; };
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            ccache
            libgcc
            gnumake
            git
            git-filter-repo
            pyright
          ];

          buildInputs = with pkgs; [ clang eigen pythonEnv ];

          EIGEN_PATH = "${pkgs.eigen}/include/eigen3";

          shellHook = ''
            export CC=gcc
            export CXX=g++
            export CXXFLAGS="-I${pkgs.eigen}/include/eigen3 ''${CXXFLAGS:-}"

            export CCACHE_DIR=$HOME/.ccache
            export PATH="$HOME/.ccache/bin:$PATH"

            alias c=clear

            echo "C++ and Python Development Environment"
            echo "======================================"
            echo "$(g++ --version | head -n 1)"
            echo "$(python --version)"
            echo "Eigen ${pkgs.eigen.version}"
            echo "$(make --version | head -n 1)"
            echo ""
            echo "Build C++ project:  nix build .#cpp"
            echo "Run C++ project:    nix run   .#cpp"
            echo "Run Python project: nix run   .#py"
            echo ""
            echo "Happy coding!"
          '';
        };
      });
}
