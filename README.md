# Base16 themes for home manager

This is a fork of [atpotts/base16-nix](https://github.com/atpotts/base16-nix)

Differences:
- Exports the home manager module as a flake output.
- Restricts scope to official base16-themes.
- Prefers the colors-only mustache template if supported, as usually I prefer to
  do my own customisation.

##  Usage

import this flake in your 'flake.nix':
```nix
inputs.base16.url = 'github:lukebfox/base16-nix';
```
then, in any home-manager configuration:
```nix
home.user.${user} = {config,pkgs,lib}:{
  imports = [ base16.hmModule ];

}
```


```nix
{pkgs, lib, config, ...}:
{
  imports = [ ./base16.nix ];
  config = {

    # Choose your themee
    themes.base16 = {
      enable = true;
      scheme = "solarized";
      variant = "solarized-dark";

      # Add extra variables for inclusion in custom templates
      extraParams = {
        fontname = mkDefault  "Inconsolata LGC for Powerline";
        headerfontname = mkDefault  "Cabin";
        bodysize = mkDefault  "10";
        headersize = mkDefault  "12";
        xdpi= mkDefault ''
          Xft.hintstyle: hintfull
        '';
    };
    };

    # 1. Use pre-provided templates
    ###############################

    programs.bash.initExtra = ''
      source ${config.lib.base16.base16template "shell"}
    '';
    home.file.".vim/colors/mycolorscheme.vim".source =
      config.lib.base16.base16template "vim";

    # 2. Use your own templates
    ###########################

    home.file.".Xresources".source = config.lib.base16.template {
      src = ./examples/Xresources;
    };
    home.file.".xmonad/xmobarrc".source = config.lib.base16.template {
      src = ./examples/xmobarrc;
    };

    # 3. Template strings directly into other home-manager configuration
    ####################################################################

    services.dunst = {
        enable = true;
        settings = with config.lib.base16.theme;
            {
              global = {
                geometry         =  "600x1-800+-3";
                font             = "${headerfontname} ${headersize}";
                icon_path =
                  config.services.dunst.settings.global.icon_folders;
                alignment        = "right";
                frame_width      = 0;
                separator_height = 0;
                sort             = true;
              };
              urgency_low = {
                background = "#${base01-hex}";
                foreground = "#${base03-hex}";
              };
              urgency_normal = {
                background = "#${base01-hex}";
                foreground = "#${base05-hex}";
              };
              urgency_critical = {
                msg_urgency = "CRITICAL";
                background  = "#${base01-hex}";
                foreground  = "#${base08-hex}";
              };
        };
     };


  };
}
```

## Reloading

Changing themes involves switching the theme definitoin and typing
`home-manager switch`. There is no attempt in general to force programs to
reload, and not all are able to reload their configs, although I have found
that reloading xmonad and occasionally restarting applications has been
enough.

You are unlikely to achieve a complet switch without logging out and logging back
in again.

## Todo

Provide better support for custom schemes (currently this assumes you'll
want to use something in the base16 repositories, but there is no reason
for this).

## Updating Sources

`cd` into the directory in which the templates.yaml and schemes.yaml are
located, and run update_sources.sh
