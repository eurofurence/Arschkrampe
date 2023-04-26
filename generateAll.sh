#!/bin/bash
FILES=scripts/*

for f in $FILES
do
	echo "NOTICE: Processing $f"
	./generate.sh $f
	echo "NOTICE: Finished $f"
done
