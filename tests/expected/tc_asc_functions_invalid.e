001: (* INVALID Function Type Checking Tests (Expected to fail) *)
002: 
003: type IntOp : integer -> integer
004: type HigherOrder : integer -> IntOp
005: type void : integer -> integer
006: 
007: function negate : IntOp
008: function get_operator : HigherOrder
009: function entry : void
010: 
011: entry(arg) := {
012:     [
013:         integer : i1; 
014:         Boolean : b1;
015:         IntOp : f_int
016:     ]
017: 
018:     (* Wrong number of arguments *)
019:     i1 := negate();
LINE 019:18 ** ERROR: syntax error, unexpected R_PAREN
020:     i1 := negate(10, 20);
LINE 020:017** ERROR: Expected 1 parameters. Actual: 2.
021:     f_int := get_operator(1, 2);
LINE 021:026** ERROR: Expected 1 parameters. Actual: 2.
022: 
023:     (* Wrong Parameter Type *)
024:     i1 := negate(true);
LINE 024:022** ERROR: Expected integer, Actual Boolean.
025:     i1 := negate('a');
LINE 025:021** ERROR: Expected integer, Actual character.
026:     f_int := get_operator(null);
LINE 026:031** ERROR: Expected integer, Actual address.
027: 
028:     (* Wrong Return Type *)
029:     b1 := negate(10);
LINE 029:007** ERROR: Expected Boolean, Actual integer.
030:     i1 := get_operator(5);
LINE 030:007** ERROR: Expected integer, Actual IntOp.
031:     f_int := is_positive;
LINE 031:025** ERROR: Variable 'is_positive' is undefined.
032: 
033:     (* Non-Functions calls *)
034:     i1 := i1(10);
LINE 034:013** ERROR: Array Index or Function Call expected.
035:     i1 := b1(true);
LINE 035:013** ERROR: Array Index or Function Call expected.
036: 
037:     (* Chaining Functions *)
038:     i1 := get_operator(5)(10)(15);
LINE 038:023** ERROR: Array Index or Function Call expected.
039: }
040: 
041: (* Invalid Return Statements *)
042: negate(x) := {
043:     return true;
LINE 043:016** ERROR: Expected integer, Actual Boolean.
044: }
045: 
046: get_operator(seed) := {
047:     return 100;
LINE 047:015** ERROR: Expected IntOp, Actual integer.
048: }
