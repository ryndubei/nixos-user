{ pkgs, ... }:

{
  programs.vscodium = {
    enable = true;
    mutableExtensionsDir = false;
    profiles.default.extensions =
      (with pkgs.vscode-extensions; [
        haskell.haskell
        justusadam.language-haskell
        mads-hartmann.bash-ide-vscode
        mkhl.direnv
        ms-python.python
        ms-pyright.pyright
        jnoortheen.nix-ide
        llvm-vs-code-extensions.vscode-clangd
        scala-lang.scala
        sumneko.lua
        teabyii.ayu
        twxs.cmake
        usernamehw.errorlens
        vscodevim.vim
      ])
      ++ (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "language-gas-x86";
          publisher = "basdp";
          version = "0.0.2";
          sha256 = "sha256-PbXhOsoR0/5wXuFrzwCcauM1uGgfQoSRTj0gPVVZ4Kg=";
        }
        {
          name = "lean4";
          publisher = "leanprover";
          version = "0.0.178";
          sha256 = "sha256-ByhiTGwlQgNkFf0BirO+QSDiXbQfR6RLQA8jM4B1+O4=";
        }
        {
          name = "gitless";
          publisher = "maattdd";
          version = "11.7.2";
          sha256 = "sha256-rYeZNBz6HeZ059ksChGsXbuOao9H5m5lHGXJ4ELs6xc=";
        }
      ]);
    profiles.default.userSettings = {
      "haskell.manageHLS" = "PATH";
      "git.enableSmartCommit" = true;
      "window.menuBarVisibility" = "toggle";
      "workbench.preferredDarkColorTheme" = "Ayu Dark Bordered";
      "window.autoDetectColorScheme" = true;
      "vim.handleKeys" = {
        "<C-k>" = false;
        "<C-b>" = false;
        "<C-p>" = false;
      };
      "editor.lineNumbers" = "relative";
      "workbench.panel.defaultLocation" = "right";
      "editor.fontFamily" = "'Fira Code', 'Droid Sans Mono', 'monospace', monospace";
      # Enable MesloLGS in the VSCodium integrated terminal
      "terminal.integrated.fontFamily" =
        "'MesloLGS Nerd Font Mono', 'Fira Code', 'Droid Sans Mono', 'monospace'";
      "editor.fontLigatures" = true;
      "[haskell]" = {
        "editor.defaultFormatter" = "haskell.haskell";
        "editor.tabSize" = 2;
        "editor.detectIndentation" = false;
        "editor.fontLigatures" = "'ss09'";
      };
      "[literate haskell]" = {
        "editor.defaultFormatter" = "haskell.haskell";
        "editor.tabSize" = 2;
        "editor.detectIndentation" = false;
        "editor.wordWrap" = "on";
        "editor.fontLigatures" = "'ss09'";
      };
      "[latex]"."editor.wordWrap" = "on";
      "editor.inlineSuggest.enabled" = true;
      "github.copilot.enable" = {
        "*" = true;
        "plaintext" = false;
        "markdown" = false;
        "yaml" = false;
        "toml" = false;
        "secret" = false;
      };
      "git.autofetch" = true;
      "haskell.formattingProvider" = "fourmolu";
      "workbench.localHistory.exclude" = {
        "*.secret" = true;
      };
      "workbench.preferredLightColorTheme" = "Quiet Light";
      "git.openRepositoryInParentFolders" = "never";
      "errorLens.removeLinebreaks" = false;
      "gitlens.telemetry.enabled" = false;
      "github.copilot.editor.enableAutoCompletions" = true;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "direnv.restart.automatic" = true;
      "haskell.plugin.notes.globalOn" = true;
      "[nix]".editor.formatOnSave = true;
      "diffEditor.ignoreTrimWhitespace" = false;
      "notebook.lineNumbers" = "on";
      "python.languageServer" = "Jedi";
      "lean4.alwaysShowTitleBarMenu" = false;
      "terminal.integrated.defaultProfile.linux" = "fish";
      # https://github.com/nix-community/vscode-nix-ide/issues/482
      "nix.hiddenLanguageServerErrors" = [ "textDocument/definition" ];
      "python.defaultInterpreterPath" = "/home/vasilysterekhov/.nix-profile/bin/python";
    };
  };
}
