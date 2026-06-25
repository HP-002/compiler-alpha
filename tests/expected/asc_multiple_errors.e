001: (* Error Recovery Stress Test *)
002: type int2int : integer -> integer
003: function broken : int2int
004: broken(a) := {
005:     [
006:         (* ERROR 1: Missing colon. *)
007:         integer badVar ;
LINE 007:17 ** ERROR: syntax error, unexpected ID, expecting COLON
008:         Boolean : flag ;
009:         
010:         (* ERROR 2: Array size must be C_INTEGER. *)
011:         type badArr : "ten" -> integer ;
LINE 011:9 ** ERROR: syntax error, unexpected TYPE
012:         character : letter
013:     ]
014:     
015:     (* ERROR 3: Horrible math expression. *)
016:     flag := a + * / 2 ;
LINE 016:17 ** ERROR: syntax error, unexpected MUL
017:     
018:     (* This valid statement MUST survive the blast radius. *)
019:     letter := 'Z' ;
020:     
021:     return a ;
022: }
