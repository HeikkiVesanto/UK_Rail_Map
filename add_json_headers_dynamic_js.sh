#!/bin/bash
cd /home/tseepra/files/rail_maps_automated/dynamic_js
FILES=*.js
for f in $FILES
do
  NAME=$f
  FILE2=${NAME::-3}
  a='var json_'
  b='_dynamic ='
  TEXT=$a$FILE2$b
  # take action on each file. $f store current file name
  echo $TEXT | cat - $f > temp && mv temp $f
done
cd /home/tseepra/files/rail_maps_automated