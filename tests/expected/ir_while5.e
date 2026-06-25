0: x = 0
1: if x < 10 goto 3
2: goto 10
3: y = 0
4: if y < 2 goto 6
5: goto 9
6: $temp5 = x + 1
7: x = $temp5
8: goto 4
9: goto 1
10: if x < 30 goto 12
11: goto 15
12: $temp8 = x + 2
13: x = $temp8
14: goto 10
15: return x
