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
10: if x goto 16
11: goto 12
12: if x goto 14
13: goto 18
14: if y goto 16
15: goto 18
16: z = true
17: goto 19
18: z = false
19: if x goto 21
20: goto 27
21: if x goto 23
22: goto 27
23: if y goto 25
24: goto 27
25: z = true
26: goto 28
27: z = false
28: if x goto 30
29: goto 36
30: if x goto 34
31: goto 32
32: if y goto 34
33: goto 36
34: z = true
35: goto 37
36: z = false
37: if x goto 39
38: goto 45
39: if x goto 43
40: goto 41
41: if y goto 43
42: goto 45
43: z = true
44: goto 46
45: z = false
46: return 0
