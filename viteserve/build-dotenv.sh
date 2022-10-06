#! /usr/bin/env bash

y_flag=''

print_usage() {
  printf "Usage: $0 [-y]"
}

# https://stackoverflow.com/a/21189044
function parse_yaml {
  local prefix=$2
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @ | tr @ '\034')
  sed -ne "s|^\($s\):|\1|" \
    -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
    -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
    awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

while getopts 'y' flag; do
  case "${flag}" in
  y) y_flag='true' ;;
  *)
    print_usage
    exit 1
    ;;
  esac
done

if [ -f .ddev/config.yaml ]; then
  eval $(parse_yaml .ddev/config.yaml)
fi

# defaults
PROJ_DIR=frontend

# check for special cases
if [ "$type" = "laravel" ]; then
  PROJ_DIR=.
fi

# @see https://stackoverflow.com/a/27650122/8600734
mapfile VITE_SETTINGS <<VITE
# start vite
VITE_PROJECT_DIR=$PROJ_DIR
VITE_PRIMARY_PORT=5173
VITE_SECONDARY_PORT=5273
# end vite
VITE

echo "New settings are:"
printf %s "${VITE_SETTINGS[@]}"
echo "--------------"
echo

cd .ddev

if [ -f "./.env" ]; then
  if grep "^# start vite" .env >/dev/null; then
    echo "Found vite settings in your .ddev/.env file."
    if [ -z "$y_flag" ]; then
      echo -n "Replace old settings (y/n)? "
      read replace
    else
      replace=y
    fi
    if [ "$replace" == "y" ]; then
      sed -i.bak '/^# start vite/,/^\# end vite/d;' .env
      printf %s "${VITE_SETTINGS[@]}" >>.env
    else
      echo "Skipping changes to your .env file."
    fi
  else
    echo "You have an existing .ddev/.env file."
    if [ -z "$y_flag" ]; then
      echo "May I append settings for this add-on to"
      echo -n "your .env file (y/n)? "
      read replace
    else
      replace=y
    fi

    if [ "$replace" == "y" ]; then
      printf %s "${VITE_SETTINGS[@]}" >>.env
    else
      echo "Skipping changes to your .env file."
    fi
  fi
else
  echo "Create a .ddev/.env file with your add-on settings:"
  printf %s "${VITE_SETTINGS[@]}" >.env
fi
echo
echo "Your .ddev/.env file now contains:"
echo "----------------------------------"
cat .env
