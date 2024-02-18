#!/bin/ash
  nc -w 1 localhost 25 | grep -qE "^220"