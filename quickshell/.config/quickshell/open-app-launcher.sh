#!/usr/bin/env bash

exec quickshell ipc call app-launcher open "$(hyprctl activeworkspace -j | jq -r '.monitor')"
