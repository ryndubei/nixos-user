function flatpakSymlinkSystemRuntimes() {
    local oldstate=$(shopt -p nullglob)

    shopt -s nullglob
    
    local flatpak_local_runtimes="$HOME/.local/share/flatpak/runtime"
    local flatpak_system_runtimes=/var/lib/flatpak/runtime
    
    if [ ! -d "$flatpak_system_runtimes" ]; then
        exit 0
    fi
    
    cd "$flatpak_system_runtimes"
    
    run mkdir -p $VERBOSE_ARG "$flatpak_local_runtimes"
    
    for r in *; do
        [ -e "$flatpak_local_runtimes/$r" ] || run ln -s $VERBOSE_ARG "$r" "$flatpak_local_runtimes/$r"
    done

    $oldstate
}

flatpakSymlinkSystemRuntimes
