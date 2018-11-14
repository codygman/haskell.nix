# package descriptions in hackage will look like:
# { system, compiler, flags, pkgs, hsPkgs, pkgconfPkgs }:
# { flags = { flag1 = false; flags2 = true; ... };
#   package = { specVersion = "X.Y"; identifier = { name = "..."; version = "a.b.c.d"; };
#               license = "..."; copyright = "..."; maintainer = "..."; author = "...";
#               homepage = "..."; url = "..."; synopsis = "..."; description = "...";
#               buildType = "Simple"; # or Custom, Autoconf, ...
#             };
#  components = {
#    "..." = { depends = [ (hsPkgs.base) ... ]; };
#    exes = { "..." = { depends = ... };
#             "..." = { depends = ... }; };
#    tests = { "..." = { depends = ... }; ... };
#  };

{ lib, config, pkgs, ... }:

with lib;
with types;

let
  # This is just like listOf, except that it filters out all null elements.
  listOfFilteringNulls = elemType: listOf elemType // {
    # Mostly copied from nixpkgs/lib/types.nix
    merge = loc: defs:
      map (x: x.value) (filter (x: x ? value && x.value != null) (concatLists (imap1 (n: def:
        if isList def.value then
          imap1 (m: def':
            (mergeDefinitions
              (loc ++ ["[definition ${toString n}-entry ${toString m}]"])
              elemType
              [{ inherit (def) file; value = def'; }]
            ).optionalValue
          ) def.value
        else
          throw "The option value `${showOption loc}` in `${def.file}` is not a list.") defs)));
  };
in {
  # This is how the Nix expressions generated by *-to-nix receive
  # their flags argument.
  config._module.args.flags = config.flags;

  options = {
    # TODO: Add descriptions to everything.
    flags = mkOption {
      type = attrsOf bool;
    };

    package = {
      specVersion = mkOption {
        type = str;
      };

      identifier.name = mkOption {
        type = str;
      };

      identifier.version = mkOption {
        type = str;
      };

      license = mkOption {
        type = str;
      };

      copyright = mkOption {
        type = str;
      };

      maintainer = mkOption {
        type = str;
      };

      author = mkOption {
        type = str;
      };

      homepage = mkOption {
        type = str;
      };

      url = mkOption {
        type = str;
      };

      synopsis = mkOption {
        type = str;
      };

      description = mkOption {
        type = str;
      };

      buildType = mkOption {
        type = str;
      };
    };

    components = let
      componentType = submodule {
        options = {
          depends = mkOption {
            type = listOfFilteringNulls unspecified;
            default = [];
          };
          libs = mkOption {
            type = listOfFilteringNulls (nullOr package);
            default = [];
          };
          frameworks = mkOption {
            type = listOfFilteringNulls package;
            default = [];
          };
          pkgconfig = mkOption {
            type = listOfFilteringNulls package;
            default = [];
          };
          build-tools = mkOption {
            type = listOfFilteringNulls unspecified;
            default = [];
          };
          configureFlags = mkOption {
            type = listOfFilteringNulls str;
            default = [];
          };
          doExactConfig = mkOption {
            type = bool;
            default = false;
          };
        };
      };
    in {
      library = mkOption {
        type = componentType;
      };
      sublibs = mkOption {
        type = attrsOf componentType;
        default = {};
      };
      foreignlibs = mkOption {
        type = attrsOf componentType;
        default = {};
      };
      exes = mkOption {
        type = attrsOf componentType;
        default = {};
      };
      tests = mkOption {
        type = attrsOf componentType;
        default = {};
      };
      benchmarks = mkOption {
        type = attrsOf componentType;
        default = {};
      };
    };

    name = mkOption {
      type = str;
      default = "${config.package.identifier.name}-${config.package.identifier.version}";
      defaultText = "\${config.package.identifier.name}-\${config.package.identifier.version}";
    };
    sha256 = mkOption {
      type = nullOr str;
      default = null;
    };
    src = mkOption {
      type = nullOr path;
      default = null;
#      defaultText = "pkgs.fetchurl { url = \"mirror://hackage/\${config.name}.tar.gz\"; inherit (config) sha256; };";
    };
    revision = mkOption {
      type = nullOr int;
      default = null;
    };
    revisionSha256 = mkOption {
      type = nullOr str;
      default = null;
    };
    patches = mkOption {
      type = listOf (either package path);
      default = [];
    };
    postUnpack = mkOption {
      type = nullOr lines;
      default = null;
    };
  };
}
