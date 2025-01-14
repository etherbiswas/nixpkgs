{ lib
, rustPlatform
, fetchCrate
, installShellFiles
, makeWrapper
, pkg-config
, ronn
, openssl
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "httplz";
  version = "1.13.1";

  src = fetchCrate {
    inherit version;
    pname = "https";
    hash = "sha256-KjkUIAo2CAfVNjC0Vq3Pd8qDN9g1+K/ZRs+sGcc8bCg=";
  };

  cargoHash = "sha256-liRCdFg1wUPIURffSJVYG9nf1UEsvSH/krglBeluvlQ=";

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
    pkg-config
    ronn
  ];

  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  cargoBuildFlags = [ "--bin" "httplz" ];

  postInstall = ''
    sed -E 's/http(`| |\(|$)/httplz\1/g' http.md > httplz.1.ronn
    RUBYOPT=-Eutf-8:utf-8 ronn --organization "http developers" -r httplz.1.ronn
    installManPage httplz.1
    wrapProgram $out/bin/httplz \
      --prefix PATH : "${openssl}/bin"
  '';

  meta = with lib; {
    description = "A basic http server for hosting a folder fast and simply";
    homepage = "https://github.com/thecoshman/http";
    changelog = "https://github.com/thecoshman/http/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ figsoda ];
  };
}
