#!/usr/bin/env bash
# https://github.com/PrismLauncher/PrismLauncher/issues/1146#issuecomment-1586109565 by Scrumplex

args=()
if [[ "$DISPLAY" == :* ]]; then
    local_socket="/tmp/.X11-unix/X${DISPLAY#?}"
    args+=(--ro-bind-try "$local_socket" "$local_socket")
    args+=(--ro-bind-try "$XAUTHORITY" "$XAUTHORITY")
fi
if [[ "$WAYLAND_DISPLAY" = /* ]]; then
    args+=(--ro-bind-try "$WAYLAND_DISPLAY" "$WAYLAND_DISPLAY")
elif [[ -n "$WAYLAND_DISPLAY" ]]; then
    args+=(--ro-bind-try "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" "/tmp/$WAYLAND_DISPLAY")
fi

# TODO --seccomp with pre-compiled filter because this is what flatpak does, see
# https://github.com/flatpak/flatpak/blob/13b1eeb0a19b91660e82fe4162ba3b413a13e72d/common/flatpak-run.c#L2056

exec bwrap \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
    --unshare-uts \
    --unshare-cgroup \
    --disable-userns \
    --die-with-parent \
    --new-session \
    --dev /dev \
    --proc /proc \
    --ro-bind /nix /nix \
    --ro-bind /etc /etc \
    --tmpfs /tmp \
    --share-net \
    --ro-bind /run/systemd/resolve /run/systemd/resolve \
    --ro-bind /run/opengl-driver /run/opengl-driver \
    --dev-bind-try /dev/dri /dev/dri \
    --dev-bind-try /dev/nvidia0 /dev/nvidia0 \
    --dev-bind-try /dev/nvidiactl /dev/nvidiactl \
    --dev-bind-try /dev/nvidia-modeset /dev/nvidia-modeset \
    --ro-bind-try /sys/class /sys/class \
    --ro-bind-try /sys/dev/char /sys/dev/char \
    --ro-bind-try /sys/devices/pci0000:00 /sys/devices/pci0000:00 \
    --ro-bind-try /sys/devices/system/cpu /sys/devices/system/cpu \
    --setenv XDG_RUNTIME_DIR /tmp \
    --ro-bind-try "$XDG_RUNTIME_DIR/pulse" /tmp/pulse \
    --ro-bind-try "$XDG_RUNTIME_DIR/pipewire-0" /tmp/pipewire-0 \
    --bind "$INST_DIR" "$INST_DIR" \
    --ro-bind "${XDG_DATA_HOME:+$HOME/.local/share}/PrismLauncher/libraries" "$HOME/.local/share/PrismLauncher/libraries" \
    --ro-bind "${XDG_DATA_HOME:+$HOME/.local/share}/PrismLauncher/assets" "$HOME/.local/share/PrismLauncher/assets" \
    --unsetenv XDG_DATA_HOME \
    --unsetenv DBUS_SESSION_BUS_ADDRESS \
    "${args[@]}" \
    -- \
    "$@"
