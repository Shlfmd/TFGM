{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  strictDeps = true;
  nativeBuildInputs = with pkgs; [
    just
    jdk21

    # Yes this mf vendors Rust. No you can't see it.
    # Why? Because I hate it. Don't complain.
    rustc
    cargo
    clippy
    rustfmt
  ];
}
