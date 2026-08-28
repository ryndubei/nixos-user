{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom.d;
  };

  services.emacs = {
    enable = true;
    client.enable = true; # Generate desktop file for client
    socketActivation.enable = true; # Launch daemon lazily
  };
}
