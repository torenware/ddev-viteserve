#! /usr/bin/env bash

# @see https://stackoverflow.com/a/27650122/8600734
mapfile VITE_SETTINGS <<'VITE'
# start vite
VITE_PROJECT_DIR=frontend
VITE_HTTP_PORT=5173
VITE_HTTPS_PORT=5273
# end vite
VITE

echo "New settings are:"
printf %s "${VITE_SETTINGS[@]}"
echo "--------------"
echo

if [ -f "./.env" ]; then
  if grep "^# start vite" .env >/dev/null; then
    echo "Found vite settings in your .ddev/.env file."
    echo -n "Replace old settings (y/n)?"
    read replace
    if [ "replace" == "y" ]; then
      sed -I .bak '/^# start vite/,/^\# end vite/d;' .env
      printf %s "${VITE_SETTINGS[@]}" >>.env
    else
      echo "Skipping changes to your .env file."
    fi
  else
    echo "You have an existing .ddev/.env file."
    echo "May I append settings for this add-on to"
    echo -n "your .env file (y/n)?"
    read replace
    if [ "replace" == "y" ]; then
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
