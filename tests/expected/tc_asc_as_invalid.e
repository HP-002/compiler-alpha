001: (* Invalid AS Tests *)
002: 
003: type Point : [integer : x; integer : y]
004: type PointOp : Point -> integer
005: type IntOp : integer -> integer
006: type void : integer -> integer
007: 
008: function bad_primitive : IntOp
009: function bad_arity_short : PointOp
010: function bad_arity_long : PointOp
011: function bad_types : PointOp
012: function entry : void
013: 
014: entry(arg) := { return 0; }
015: 
016: (* AS with primitive type *)
017: bad_primitive as (x) := {
LINE 017:020** ERROR: 'as' only permitted for record types. Actual: integer.
018:     return x;
LINE 018:013** ERROR: Variable 'x' is undefined.
019: }
020: 
021: (* Less identifiers *)
022: bad_arity_short as (x) := {
LINE 022:022** ERROR: Expected 2 parameters. Actual: 1.
023:     return x;
024: }
025: 
026: (* Many identifiers *)
027: bad_arity_long as (x, y, z) := {
LINE 027:021** ERROR: Expected 2 parameters. Actual: 3.
028:     return x + y;
029: }
030: 
031: bad_types as (px, py) := {
032:     [ Boolean : b1 ]
033:     
034:     b1 := px;
LINE 034:007** ERROR: Expected Boolean, Actual integer.
035:     
036:     return px;
037: }
