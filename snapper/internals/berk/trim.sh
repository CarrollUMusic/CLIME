#!/bin/bash
for i in *.wav
do
  sox $i trimmed/$i silence 1 1 0.1%
done

