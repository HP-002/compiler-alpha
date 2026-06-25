0: x = 0
1: if x < 2 goto 3
2: goto 6
3: $temp3 = x + 1
4: x = $temp3
5: goto 1
6: if x < 10 goto 8
7: goto 11
8: $temp6 = x + 2
9: x = $temp6
10: goto 6
11: return x
