{ lib, steamappidlist }:

let
  list = path:
    builtins.filter (x: x != null)
    (builtins.fromJSON (builtins.readFile "${steamappidlist}/${path}"));
  extract = path:
    builtins.listToAttrs (builtins.map ({ name, appid, ... }: {
      inherit name;
      value = appid;
    }) (list path));
  steam-app-ids = {
    games = extract "/data/games_appid.json";
    dlc = extract "/data/dlc_appid.json";
  };
  f = category: data: rec {
    # name -> appid attrset
    inherit data;

    # appid -> name attrset
    inverted =
      lib.attrsets.concatMapAttrs (name: appid: { "${toString appid}" = name; })
      data;

    # Get the name for a given appid
    getName = appid:
      if builtins.hasAttr (toString appid) inverted then
        inverted.${toString appid}
      else
        throw "No such appid in list: ${toString appid}";

    # Get the appid for a given name
    getAppId = name: data."${name}";

    # Convert either an app name or an appid to a set with both fields
    normalise = id:
      assert builtins.typeOf id == "int" || builtins.typeOf id == "string";
      if builtins.typeOf id == "int" then {
        appid = id;
        name = getName id;
      } else {
        appid = getAppId id;
        name = id;
      };
  };
in builtins.mapAttrs f steam-app-ids
