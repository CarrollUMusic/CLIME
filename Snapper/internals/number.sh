#!/bin/bash
a=0
for i in *
do
  mv "$i" $a.wav
  ((a++))
done

