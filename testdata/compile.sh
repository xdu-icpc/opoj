#!/bin/sh
g++ -DONLINE_JUDGE -fno-tree-ch -O2 -Wall -std=c++14 -pipe -lm $1 -o prog

if [ "$?" = "0" ]; then
	exit 0
fi

g++ -DONLINE_JUDGE -fno-tree-ch -O2 -Wall -std=c++11 -pipe -lm $1 -o prog

if [ "$?" = "0" ]; then
	exit 0
fi

g++ -DONLINE_JUDGE -fno-tree-ch -O2 -Wall -std=c++03 -pipe -lm $1 -o prog
