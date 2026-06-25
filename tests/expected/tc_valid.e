001: type Unary : integer -> integer
002: function entry : Unary
003: 
004: entry(x) := {
005:     [
006:         integer : a;
007:         integer : b;
008:         Boolean : flag
009:     ]
010:     a := 1 + 2 * 3;
011:     b := a - 4 / 2 % 3;
012:     flag := true & false | !true;
013:     if (a < b) then {
014:         a := b;
015:     } else {
016:         b := a;
017:     }
018:     flag := a = b;
019:     return a;
020: }
