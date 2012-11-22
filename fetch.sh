#!/bin/sh

export RAILS_ENV=production

if [ -z "$1" ]; then
  exec rails runner Account.fetch_all
else
  exec rails runner "Account.where(id: '$1').fetch_all"
fi
