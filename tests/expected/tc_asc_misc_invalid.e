001: (* Invalid Misc Tests *)
002: 
003: type Point : [integer : x; integer : y]
004: type Circle : [Point : center; integer : radius]
005: 
006: type Grid3D : 3 -> integer
007: 
008: type IntOp : integer -> integer
009: 
010: function bad_access : IntOp
011: 
012: bad_access(n) := {
013:     [
014:         Circle : c1;
015:         Grid3D : space;
016:         integer : i1
017:     ]
018: 
019:     c1.center.z := 10;
LINE 019:016** ERROR: Field 'z' not found in record 'Point'.
020:     
021:     c1.radius.x := 5;
LINE 021:014** ERROR: Array dimension lookup or Record Access expected.
022:     
023:     i1 := c1.center;
LINE 023:007** ERROR: Expected integer, Actual Point.
024: 
025: 
026:     space(1, 2) := 10;
LINE 026:010** ERROR: Expected 3 dimensions. Actual: 2.
LINE 026:010** ERROR: Expected Grid3D, Actual integer.
027:     
028:     space(1, 2, 3, 4) := 10;
LINE 028:010** ERROR: Expected 3 dimensions. Actual: 4.
LINE 028:010** ERROR: Expected Grid3D, Actual integer.
029:     
030:     space(1, c1.center, 3) := 5;
LINE 030:023** ERROR: Integer expected. Actual type: Point
031: 
032:     i1 := arg;
LINE 032:014** ERROR: Variable 'arg' is undefined.
033:     
034:     result := 10;
LINE 034:011** ERROR: Variable 'result' is undefined.
035: 
036:     return 0;
037: }
