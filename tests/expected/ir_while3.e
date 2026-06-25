0: i = 0
1: sum = 0
2: if i < 5 goto 4
3: goto 15
4: j = 0
5: if j < 5 goto 7
6: goto 12
7: $temp6 = sum + 1
8: sum = $temp6
9: $temp8 = j + 1
10: j = $temp8
11: goto 5
12: $temp10 = i + 1
13: i = $temp10
14: goto 2
15: return sum
