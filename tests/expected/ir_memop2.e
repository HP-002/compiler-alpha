0: $temp2 = 5 * 4
1: $temp4 = $temp2 + 4
2: param $temp4
3: $temp5 = call reserve
4: $temp5[0] = 5
5: arr = $temp5
6: param arr
7: call release
8: arr = null
9: return 0
