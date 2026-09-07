#!/usr/bin/bash

wlopm --off '*'

sleep 0.5


read -n 1 -s -r
kill -9 $PPID
wlopm --on '*'
