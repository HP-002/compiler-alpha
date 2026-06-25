0: $temp4 = arr[0]
1: if 1 < 0 goto 13
2: if 1 < $temp4 goto 4
3: goto 13
4: $temp6 = arr[4]
5: if 1 < 0 goto 13
6: if 1 < $temp6 goto 8
7: goto 13
8: $temp7 = 1 * $temp6
9: $temp8 = $temp7 + 1
10: $temp10 = $temp8 * 4
11: $temp12 = $temp10 + 8
12: goto 14
13: call .crash
14: $temp13 = arr[$temp12]
15: x = $temp13
16: return 0
