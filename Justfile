# Build README
build-readme:
    @python make_readme.py
    @sh .github/make-readme.sh

# Create sandbox
create-sandbox sandbox:
    @mkdir -v "{{ justfile_directory() }}/{{ sandbox }}"
    @cd "{{ justfile_directory() }}/{{ sandbox }}" \
        && nix flake init -t "{{ justfile_directory() }}#templates.shell"

# Create sandbox with Flake
create-sandbox-flake sandbox:
    @mkdir -v "{{ justfile_directory() }}/{{ sandbox }}"
    @cd "{{ justfile_directory() }}/{{ sandbox }}" \
        && nix flake init -t "{{ justfile_directory() }}#templates.flake"
