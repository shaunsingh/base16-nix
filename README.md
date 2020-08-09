# Base16 themes for home manager

This is a fork of [lukebfox/base16-nix](https://github.com/lukebfox/base16-nix)

Differences:

- Returns support for obtaining color values from the color scheme
- Added possibility to select a template type (`'default'`, `'color'`, etc)
- Removed unused files

## Usage

import this flake in your 'flake.nix':

```nix
inputs.base16.url = 'github:alukardbf/base16-nix';
```

then, in any home-manager configuration:

```nix
home.user.${user} = { config, pkgs, lib }: {
  imports = [ base16.hmModule ];

}
```

```nix
{ pkgs, lib, config, ...}:
{
  config = {

    # Choose your theme
    themes.base16 = {
      enable = true;
      scheme = "solarized";
      variant = "solarized-dark";
      defaultTemplateType = "default";
      # Add extra variables for inclusion in custom templates
      extraParams = {
        fontName = "Roboto Mono";
        fontSize = "12";
      };
    };

    # 1. Use pre-provided templates
    ###############################

    programs.bash.initExtra = ''
      source ${config.lib.base16.templateFile { name = "shell"; };}
    '';
    programs.rofi = {
      enable = true;
      theme = "${config.lib.base16.templateFile { name = "rofi"; type = "color"; };}";
    };

    # 2. Template strings directly into other home-manager configuration
    ####################################################################

    services.dunst = {
        enable = true;
        settings = with config.lib.base16.theme;
            {
              global = {
                geometry         =  "600x1-800+-3";
                icon_path =
                  config.services.dunst.settings.global.icon_folders;
                alignment        = "right";
                font = "${fontName} ${fontSize}";
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

Changing themes involves switching the theme definition and typing
`home-manager switch`. There is no attempt in general to force programs to
reload, and not all are able to reload their configs, although I have found
that reloading xmonad and occasionally restarting applications has been
enough.

You are unlikely to achieve a complete switch without logging out and logging back
in again.

## Todo

Provide better support for custom schemes (currently it
is assumed that you'll use something in base16
repositories, but there is no reason to).

## Updating Sources

If you're using nix flakes:

- Fork this repository
- `cd` into repository dir
- Enter `nix develop` and then run `update-base16`
- Commit and push new files

If you're **not** using nix flakes:

- `cd` into repository dir
- Run `update_sources.sh`
