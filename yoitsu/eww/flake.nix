{
  description = "python program";

  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    };

  outputs = { self, nixpkgs }:
    let

    system = "x86_64-linux";

    pkgs = import nixpkgs { inherit system; };

    python = (pkgs.python311.withPackages (pythonPackages: with pythonPackages; [
        dbus-python
        pygobject3
        jedi-language-server
      ]));
  in
  {
    devShells.${system}.default =
      pkgs.mkShell {
        propagatedBuildInputs = [
            eww-wayland # or just eww for X
            python
            # just in case lsp does not see dependencies
            pkgs.python311Packages.dbus-python
            pkgs.python311Packages.pygobject3
            pkgs.python311Packages.jedi-language-server
        ];
      };
  };
}
