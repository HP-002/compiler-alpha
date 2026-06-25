0: param 16
1: $temp1 = call reserve
2: p = $temp1
3: p[0] = 5
4: $temp5 = p[8]
5: a = $temp5
6: param p
7: call release
8: p = null
9: return a
