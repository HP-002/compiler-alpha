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
10: if true goto 12
11: goto 14
12: z = true
13: goto 15
14: z = false
15: if x goto 21
16: goto 17
17: if y goto 21
18: goto 19
19: if z goto 21
20: goto 23
21: z = true
22: goto 24
23: z = false
24: if x goto 26
25: goto 32
26: if y goto 28
27: goto 32
28: if z goto 30
29: goto 32
30: z = true
31: goto 33
32: z = false
33: if x goto 35
34: goto 37
35: if y goto 39
36: goto 37
37: if z goto 39
38: goto 41
39: z = true
40: goto 42
41: z = false
42: if x goto 48
43: goto 44
44: if y goto 46
45: goto 50
46: if z goto 48
47: goto 50
48: z = true
49: goto 51
50: z = false
51: return 0
