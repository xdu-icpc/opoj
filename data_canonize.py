#!/usr/bin/env python3

import sys
inf = sys.argv[1]

o = []

with open(inf) as f:
    for l in f:
        o.append(l.rstrip())

if len(o) and o[-1] == "":
    o.pop()

for i in o:
    print(i)
