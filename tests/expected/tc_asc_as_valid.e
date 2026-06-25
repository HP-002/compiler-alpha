001: (* Valid AS Tests *)
002: 
003: type Point : [integer : x; integer : y; Boolean : is_valid]
004: type PointOp : Point -> integer
005: type void : integer -> integer
006: 
007: function process_point : PointOp
008: function entry : void
009: 
010: entry(arg) := {
011:     [ Point : p1; integer : i1 ]
012:     
013:     p1 := reserve p1;
014:     p1.x := 10;
015:     p1.y := 20;
016:     p1.is_valid := true;
017: 
018:     i1 := process_point(p1);
019: }
020: 
021: (* Using AS to unpack the 3 fields into local variables px, py, and valid *)
022: process_point as (px, py, valid) := {
023:     [ integer : result ]
024:     
025:     if (valid) then {
026:         (* px and py are correctly identified as integers by the compiler *)
027:         result := px + py; 
028:     } else {
029:         result := 0;
030:     }
031:     
032:     return result;
033: }
