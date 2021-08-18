#!/bin/sh

# close all
for d in $(bspc query -N); do
  bspc node $d -c
done
wait
bspc quit
