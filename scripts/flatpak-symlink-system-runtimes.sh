function flatpakSymlinkSystemRuntimes() {
    local oldstate=$(shopt -p nullglob)

    shopt -s nullglob
    
    local flatpak_local_runtimes="$HOME/.local/share/flatpak/runtime"
    local flatpak_system_runtimes=/var/lib/flatpak/runtime
    
    run mkdir -p $VERBOSE_ARG "$flatpak_local_runtimes"
    
    for r in "$flatpak_system_runtimes"/*; do
        local r_destination="$flatpak_local_runtimes/$(basename $r)"
        [ -e "$r_destination" ] || run ln -s $VERBOSE_ARG "$r" "$r_destination"
    done

    $oldstate
}

flatpakSymlinkSystemRuntimes
