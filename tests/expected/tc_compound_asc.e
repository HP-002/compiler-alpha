001: type Unary : integer -> integer
002: function entry : Unary
003: 
004: entry(x) := {
005:     [
006:         integer : a;
007:         Boolean : flag
008:     ]
009:     if (5) then {
LINE 009:010** ERROR: Boolean expected. Actual type: integer
010:         a := 1;
011:     } else {
012:         a := 2;
013:     }
014:     while (a + 1) {
LINE 014:013** ERROR: Boolean expected. Actual type: integer
015:         a := a - 1;
016:     }
017:     if (flag) then {
018:         a := 0;
019:     } else {
020:         a := 1;
021:     }
022:     return a;
023: }
