001: (* should execute cleanly *)
002: type IntArray : 50 -> integer
003: type int2int : integer -> integer
004: function compute : int2int
005: compute(x) := {
006:     [
007:         integer : i ;
008:         integer : result ;
009:         address : ptr
010:     ]
011:     i := 0 ;
012:     result := -x + i * (5 / 2) % 3 ;
013:     ptr := reserve IntArray ;
014:     
015:     while (i < 10 & !(result = 0)) {
016:         if (result < 0 | x = i) then {
017:             result := result + 1 ;
018:         } else {
019:             result := result.ptr - 1 ;
020:         }
021:         i := i + 1 ;
022:     }
023:     return result ;
024: }