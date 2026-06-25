0: param 24
1: $temp1 = call reserve
2: v = $temp1
3: v[0] = 1
4: v[8] = 2
5: v[16] = 3
6: $temp9 = v[0]
7: $temp11 = v[8]
8: $temp12 = $temp9 + $temp11
9: $temp14 = v[16]
10: $temp15 = $temp12 + $temp14
11: sum = $temp15
12: param v
13: call release
14: v = null
15: return sum
