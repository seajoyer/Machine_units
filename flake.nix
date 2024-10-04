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

        # Define the C++ project
        cppProject = pkgs.clangStdenv.mkDerivation {
          name = "Machine_units";
          src = ./.;

          nativeBuildInputs = with pkgs; [ gnumake ];

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

        pythonProject = pkgs.writeScriptBin "run-python" ''
          #!${pythonEnv}/bin/python
          import sys
          sys.path.insert(0, "${./.}")
          exec(open("Machine_units/py/main.py").read())
        '';

      in {
        packages = {
          machine_units-cpp = cppProject;
          machine_units-py = pythonProject;
          default = cppProject;
        };

        apps = {
          machine_units-cpp = flake-utils.lib.mkApp { drv = cppProject; };
          machine_units-py = flake-utils.lib.mkApp { drv = pythonProject; };
          default = flake-utils.lib.mkApp { drv = cppProject; };
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            ccache
            gnumake
            git
            git-filter-repo
            pyright
          ];

          buildInputs = with pkgs; [ clang libcxx eigen pythonEnv ];

          EIGEN_PATH = "${pkgs.eigen}/include/eigen3";

          shellHook = ''
            export CC=clang
            export CXX=clang++
            export CXXFLAGS="-I${pkgs.eigen}/include/eigen3 ''${CXXFLAGS:-}"

            export CCACHE_DIR=$HOME/.ccache
            export PATH="$HOME/.ccache/bin:$PATH"

            alias c=clear

            echo "C++ and Python Development Environment"
            echo "======================================"
            echo "$(clang --version | head -n 1)"
            echo "$(python --version)"
            echo "Eigen ${pkgs.eigen.version}"
            echo "$(make --version | head -n 1)"
            echo ""
            echo "Build C++ project:  nix build .#machine_units-cpp"
            echo "Run C++ project:    nix run   .#machine_units-cpp"
            echo "Run Python project: nix run   .#machine_units-py"
            echo ""
            echo "Happy coding!"
          '';
        };
      }
    );
}
