{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.themes.base16;
  inherit (builtins) pathExists;
  
  schemes   = importJSON ./schemes.json;
  templates = importJSON ./templates.json;

  # Data file for a given base16 scheme and variant. Returns the nix store
  # path of the file.
  mkTheme = scheme: variant:
    "${pkgs.fetchgit (schemes."${scheme}")}/${variant}.yaml";

  # Source file for a given base16 template. Use the colors-only template
  # if one exists, as I generally prefer to do my own customisations.
  # Returns the nix store path of the file.
  mkTemplate = name:
  let
    templateDir = "${pkgs.fetchgit (templates."${name}")}/templates";
    in
    if pathExists (templateDir + "/colors.mustache")
    then templateDir + "/colors.mustache"
    else templateDir + "/default.mustache";

  # The theme yaml files only supply 16 hex values, but the templates take
  # a transformation of this data such as rgb. The hacky python script pre-
  # processes the theme file in this way for consumption by the mustache
  # engine below.
  python = pkgs.python.withPackages (ps: [ ps.pyyaml ]);
  preprocess = src:
    pkgs.stdenv.mkDerivation {
      name = "placeholder-change-me";
      inherit src;
      builder = pkgs.writeText "builder.sh" ''
            slug_all=$(${pkgs.coreutils}/bin/basename $src)
            slug=''${slug_all%.*}
            ${python}/bin/python ${./base16writer.py} $slug < $src > $out
          '';
      allowSubstitutes = false;  # will never be in cache
    };

  # Mustache engine. Applies any theme to any template, providing they are
  # included in the local json source files.
  mustache = scheme: variant: name:
    pkgs.stdenv.mkDerivation {
      name = "${name}-base16-${variant}";
      data = preprocess (mkTheme scheme variant);
      src  = mkTemplate name;
      phases = [ "buildPhase" ];
      buildPhase ="${pkgs.mustache-go}/bin/mustache $data $src > $out";
      allowSubstitutes = false;  # will never be in cache
    };

in
{
  options = {
    themes.base16.enable = mkEnableOption "Base 16 Color Schemes";
    themes.base16.scheme = mkOption {
      type=types.str;
      default="tomorrow";
    };
    themes.base16.variant = mkOption {
      type=types.str;
      default="tomorrow";
    };
    themes.base16.tone = mkOption
  };
  config = {
    lib.base16.base16template = mustache cfg.scheme cfg.variant;
  };
}
