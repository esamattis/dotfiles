#!/bin/sh

set -eu

exec op item get "$OP_ITEM_ID" --reveal --fields password
