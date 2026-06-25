001: (* Valid Misc Tests *)
002: 
003: type Point : [integer : x; integer : y]
004: type Circle : [Point : center; integer : radius]
005: type Sphere : [Circle : base; integer : z_height]
006: 
007: type Grid3D : 3 -> integer
008: 
009: type IntOp : integer -> integer
010: type void : integer -> integer
011: 
012: function factorial : IntOp
013: function process_grid : IntOp
014: function entry : void
015: 
016: entry(arg) := {
017:     [
018:         Sphere : s1;
019:         Grid3D : space;
020:         integer : i1
021:     ]
022: 
023:     s1 := reserve s1;
024: 
025:     s1.base.center.x := 10;
026:     s1.base.center.y := 20;
027:     s1.base.radius := 5;
028:     s1.z_height := 100;
029: 
030:     space := reserve space(10, 10, 10);
031:     space(0, 5, 9) := s1.base.center.x * 2; 
032: 
033:     if ( (s1.base.center.x < s1.base.center.y) & (space(0,5,9) = 20) | !(s1.z_height < 0) ) then {
034:         i1 := factorial(5);
035:     } else {
036:         i1 := 0;
037:     }
038: }
039: 
040: factorial(n) := {
041:     [ integer : result ]
042:     
043:     if (n < 2) then {
044:         result := 1;
045:     } else {
046:         result := n * factorial(n - 1);
047:     }
048:     
049:     return result;
050: }
