001: type IntOp : integer -> integer
002: function entry : IntOp
003: 
004: entry(arg) := {
005:     [ integer : x; integer : y ]
006: 
007:     x := 10;
008:     
009:     if (x < 10) {
LINE 009:17 ** ERROR: syntax error, unexpected L_BRACE, expecting THEN
010:         y := 1;
011:     } else {
012:         y := 0;
013:     }
014:     
015:     return y;
016: }
