#! /usr/bin/env bash
#ddev-generated
cd .ddev
if [ -f .allow-upgrade ]; then
  if grep "true" .allow-upgrade >/dev/null; then
    if [ -f .env ]; then
      sed -i.bak '/^# start vite/,/^\# end vite/d;' .env
      cat .env-frag >>.env
      echo ".env updated to:"
      cat .env
    else
      cp .env-frag .env
    fi
    # rm .env-frag
  fi
fi
