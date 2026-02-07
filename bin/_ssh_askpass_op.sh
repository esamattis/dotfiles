#!/bin/sh

set -eu

# $1 is like "Enter passphrase for /Users/esamatti/.ssh/id_ed25519_personal_github:"
file_path=$(echo "$1" | sed -E 's/.* for (.+): $/\1/')
ip_id_file="${file_path}.op"

if [ ! -f "$ip_id_file" ]; then
   >&2 echo "1pw ssh askpass error: no id file: $ip_id_file"
   exit 1
fi

op_item_id="$(cat "$ip_id_file")"

>&2 echo "Asking $op_item_id from 1Password"
exec op item get --vault CLI "$op_item_id" --reveal --fields password
