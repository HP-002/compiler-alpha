0: if false goto 2
1: goto 4
2: y = true
3: goto 5
4: y = false
5: if i < j goto 7
6: goto 9
7: z = true
8: goto 10
9: z = false
10: if i = j goto 12
11: goto 14
12: z = true
13: goto 15
14: z = false
15: if i < j goto 17
16: goto 25
17: if i = 10 goto 19
18: goto 25
19: if x goto 21
20: goto 23
21: if y goto 25
22: goto 23
23: if i = j goto 27
24: goto 25
25: z = true
26: goto 28
27: z = false
28: return 0
