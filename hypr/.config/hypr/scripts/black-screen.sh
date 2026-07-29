#!/usr/bin/bash

wlopm --off '*'

sleep 0.5


read -n 1 -s -r

wlopm --on '*'
