upd_32 () {
  cp --update=none steam_api.dll steam_api_o.dll
  cp $smokeapi32_dll steam_api.dll
}
upd_64 () {
  cp --update=none steam_api64.dll steam_api64_o.dll
  cp $smokeapi64_dll steam_api64.dll
}
export -f upd_32
export -f upd_64

IFS=$'\n'
for path in $paths; do
  cd $path
  find -type f -name "steam_api.dll" -execdir bash -c upd_32 bash \;
  find -type f -name "steam_api64.dll" -execdir bash -c upd_64 bash \;
done
