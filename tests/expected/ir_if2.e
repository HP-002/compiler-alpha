0: x = 10
1: y = 0
2: if x < 5 goto 4
3: goto 7
4: $temp4 = y + 1
5: y = $temp4
6: goto 9
7: $temp6 = y + 2
8: y = $temp6
9: if x = 10 goto 11
10: goto 14
11: $temp9 = y + 10
12: y = $temp9
13: goto 16
14: $temp11 = y + 20
15: y = $temp11
16: return y
