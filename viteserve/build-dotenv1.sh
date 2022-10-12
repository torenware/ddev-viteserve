#! /usr/bin/env bash
#ddev-generated

y_flag=''

print_usage() {
  printf "Usage: $0 [-y]"
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

# defaults
PROJ_DIR=frontend

# check for special cases
if [ "$DDEV_PROJECT_TYPE" = "laravel" ]; then
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

echo
echo "New settings are:"
printf %s "${VITE_SETTINGS[@]}"
echo "--------------"
echo

cd .ddev
if [ -f .allow-upgrade ]; then
  rm .allow-upgrade
fi
printf %s "${VITE_SETTINGS[@]}" >.env-frag

allow_upgrade=${y_flag}

if [ "$allow_upgrade" = "" ]; then
  if [ ! -f "./.env" ]; then
    allow_upgrade="true"
  else
    if grep "^# start vite" .env >/dev/null; then
      echo "Found vite settings in your .ddev/.env file."
      echo -n "Replace old settings (y/n)? "
      allow_upgrade=ask
    fi
  fi
fi
echo $allow_upgrade >.allow-upgrade
