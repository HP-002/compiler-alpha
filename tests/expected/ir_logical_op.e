0: if true goto 2
1: goto 4
2: a = true
3: goto 5
4: a = false
5: if false goto 7
6: goto 9
7: b = true
8: goto 10
9: b = false
10: if a goto 12
11: goto 16
12: if b goto 14
13: goto 16
14: a = true
15: goto 17
16: a = false
17: if a goto 21
18: goto 19
19: if b goto 21
20: goto 23
21: a = true
22: goto 24
23: a = false
24: if a goto 26
25: goto 32
26: if a goto 30
27: goto 28
28: if b goto 30
29: goto 32
30: a = true
31: goto 33
32: a = false
33: return 0
