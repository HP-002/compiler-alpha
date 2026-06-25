0: x = 10
1: evenCount = 0
2: oddCount = 0
3: if 0 < x goto 5
4: goto 16
5: $temp5 = x % 2
6: if $temp5 = 0 goto 8
7: goto 11
8: $temp8 = evenCount + 1
9: evenCount = $temp8
10: goto 13
11: $temp10 = oddCount + 1
12: oddCount = $temp10
13: $temp12 = x - 1
14: x = $temp12
15: goto 3
16: return 0
