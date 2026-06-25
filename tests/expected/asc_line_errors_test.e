001: type int2int : integer -> integer
002: function multi : int2int
003: multi(x) := {
004:     [ integer : y ]
005:     
006:     y := + 2 ; x := * 3 ; y := / 4 ;
LINE 006:10 ** ERROR: syntax error, unexpected ADD
LINE 006:21 ** ERROR: syntax error, unexpected MUL
LINE 006:32 ** ERROR: syntax error, unexpected DIV
007:     
008:     return y ;
009: }
