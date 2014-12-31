#!/bin/bash
a=0
for i in *.wav
do
  avconv -i "$i" -ar 44100 -ab 16 $a.wav
  ((a++))
done

