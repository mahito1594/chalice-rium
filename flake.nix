{
  description = "Ruby on Rails development environment for chalice-rium";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            ruby_3_4
            postgresql_16
            libyaml
            pkg-config
          ];

          shellHook = ''
            # gem install の書き込み先をプロジェクトローカルに設定
            export GEM_HOME="$PWD/tmp/gems"
            export PATH="$GEM_HOME/bin:$PATH"

            export PGDATA="$PWD/tmp/postgres/data"
            export PGHOST="$PWD/tmp/postgres/data"

            if [ ! -d "$PGDATA" ]; then
              echo "Initializing PostgreSQL data directory at $PGDATA ..."
              initdb --no-locale --encoding=UTF8 --auth=trust "$PGDATA"
            fi

            if ! pg_ctl status -D "$PGDATA" > /dev/null 2>&1; then
              pg_ctl start -D "$PGDATA" \
                -l "$PWD/tmp/postgres/log" \
                -o "-k $PGDATA -c listen_addresses="
            fi
          '';
        };
      }
    );
}
