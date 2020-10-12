#!/usr/bin/env python3

import sys
score = sys.argv[1:]
tot = 0.0
for i in score:
    with open(i) as f:
        for l in f:
            tot += eval(l) * 100

print(tot)
