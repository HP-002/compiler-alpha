0: if true goto 2
1: goto 4
2: x = true
3: goto 5
4: x = false
5: if false goto 7
6: goto 9
7: y = true
8: goto 10
9: y = false
10: if x goto 14
11: goto 12
12: if y goto 14
13: goto 16
14: z = true
15: goto 17
16: z = false
17: if z goto 19
18: goto 23
19: if y goto 21
20: goto 23
21: z = true
22: goto 24
23: z = false
24: if x goto 28
25: goto 26
26: z = true
27: goto 29
28: z = false
29: return 0
