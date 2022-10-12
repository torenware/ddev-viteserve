#! /usr/bin/env bash
#ddev-generated
cd .ddev
if [ -f .allow-upgrade ]; then
  if grep "true" .allow-upgrade >/dev/null; then
    if [ -f .env ]; then
      sed -i.bak '/^# start vite/,/^\# end vite/d;' .env
      # strip weird null characters from sed output.
      tr <.env -d '\000' >.env-post-sed
      cat .env-post-sed .env-frag >.env
      echo ".env updated to:"
      cat .env
      rm .env-post-sed
    else
      cp .env-frag .env
    fi
    rm .env-frag
  fi
fi
