0: $temp3 = arr[0]
1: if 5 < 0 goto 7
2: if 5 < $temp3 goto 4
3: goto 7
4: $temp5 = 5 * 4
5: $temp7 = $temp5 + 4
6: goto 8
7: call .crash
8: $temp8 = arr[$temp7]
9: x = $temp8
10: return 0
