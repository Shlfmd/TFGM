{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  strictDeps = true;
  nativeBuildInputs = with pkgs; [
    just
    jdk21
    shellcheck
  ];
}
