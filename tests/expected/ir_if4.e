0: x = 10
1: if x < 10 goto 3
2: goto 9
3: if x = 5 goto 5
4: goto 7
5: y = 1
6: goto 8
7: y = 2
8: goto 14
9: if x = 15 goto 11
10: goto 13
11: y = x
12: goto 14
13: y = y
14: if x = 999 goto 16
15: goto 18
16: y = 999
17: goto 19
18: y = y
19: return y
