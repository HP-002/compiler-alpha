001: (* Invalid Tests for expressions *)
002: 
003: type Point : [integer : x; integer : y; Boolean : b; character : c]
004: type IntArray: 1 -> integer
005: type int2int: integer -> integer
006: 
007: function func1 : int2int
008: function func2 : int2int
009: 
010: type void : integer -> integer
011: function entry : void
012: 
013: entry(x) := {
014:     [integer : i1; integer : i2;
015:      character : c1; character : c2;
016:      Boolean : b1; Boolean : b2;
017:      Point : p1; Point : p2;
018:      IntArray: arr1; IntArray: arr2 ]
019: 
020:     (* Boolean Expressions *)
021:     b1 := 1;
LINE 021:007** ERROR: Expected Boolean, Actual integer.
022:     b1 := 'a';
LINE 022:007** ERROR: Expected Boolean, Actual character.
023:     b1 := null;
LINE 023:007** ERROR: Expected Boolean, Actual address.
024:     b1 := p1;
LINE 024:007** ERROR: Expected Boolean, Actual Point.
025:     b1 := i1 + i2;
LINE 025:007** ERROR: Expected Boolean, Actual integer.
026:     b1 := true + false;
LINE 026:015** ERROR: Integer expected. Actual type: Boolean
LINE 026:023** ERROR: Integer expected. Actual type: Boolean
LINE 026:007** ERROR: Expected Boolean, Actual integer.
027:     b1 := b1 - 1;
LINE 027:013** ERROR: Integer expected. Actual type: Boolean
LINE 027:007** ERROR: Expected Boolean, Actual integer.
028:     b1 := true * 10;
LINE 028:015** ERROR: Integer expected. Actual type: Boolean
LINE 028:007** ERROR: Expected Boolean, Actual integer.
029: 
030:     b1 := true < 10;
LINE 030:020** ERROR: Expected Boolean, Actual integer.
031:     b1 := 'a' = false;
LINE 031:014** ERROR: Comparison of different types: character and Boolean
032:     b1 := b1 = i1;
LINE 032:013** ERROR: Comparison of different types: Boolean and integer
033:     b1 := !i1;
LINE 033:014** ERROR: Boolean expected. Actual type: integer
034:     b1 := !c1;
LINE 034:014** ERROR: Boolean expected. Actual type: character
035:     b1 := !null;
LINE 035:016** ERROR: Boolean expected. Actual type: address
036:     b1 := !(i1 + i2);
LINE 036:015** ERROR: Boolean expected. Actual type: integer
037: 
038:     b1 := b1 | 10;
LINE 038:018** ERROR: Boolean expected. Actual type: integer
039:     b1 := 'a' | false;
LINE 039:014** ERROR: Boolean expected. Actual type: character
040:     b1 := null | null;
LINE 040:015** ERROR: Boolean expected. Actual type: address
LINE 040:022** ERROR: Boolean expected. Actual type: address
041:     b1 := (i1 < i2) | i1;
LINE 041:025** ERROR: Boolean expected. Actual type: integer
042:     b1 := b1 & c1;
LINE 042:018** ERROR: Boolean expected. Actual type: character
043:     b1 := 0 & 1;
LINE 043:012** ERROR: Boolean expected. Actual type: integer
LINE 043:016** ERROR: Boolean expected. Actual type: integer
044:     b1 := true & p1;
LINE 044:020** ERROR: Boolean expected. Actual type: Point
045: 
046:     (* Integer Expressions *)
047:     i1 := true;
LINE 047:007** ERROR: Expected integer, Actual Boolean.
048:     i1 := 'x';
LINE 048:007** ERROR: Expected integer, Actual character.
049:     i1 := null;
LINE 049:007** ERROR: Expected integer, Actual address.
050:     i1 := p1;
LINE 050:007** ERROR: Expected integer, Actual Point.
051:     i1 := arr1;
LINE 051:007** ERROR: Expected integer, Actual IntArray.
052: 
053:     i1 := i1 < i2;
LINE 053:007** ERROR: Expected integer, Actual Boolean.
054:     i1 := i1 = 10;
LINE 054:007** ERROR: Expected integer, Actual Boolean.
055:     i1 := (i1 + 5) < 20;
LINE 055:007** ERROR: Expected integer, Actual Boolean.
056: 
057:     i1 := i1 + true;
LINE 057:020** ERROR: Integer expected. Actual type: Boolean
058:     i1 := 'a' - i2;
LINE 058:014** ERROR: Integer expected. Actual type: character
059:     i1 := i1 * null;
LINE 059:020** ERROR: Integer expected. Actual type: address
060:     i1 := p1 / 10;
LINE 060:013** ERROR: Integer expected. Actual type: Point
061:     i1 := b1 % i2;
LINE 061:013** ERROR: Integer expected. Actual type: Boolean
062:     i1 := -true;
LINE 062:016** ERROR: Integer expected. Actual type: Boolean
063:     i1 := -'c';
LINE 063:015** ERROR: Integer expected. Actual type: character
064:     i1 := -null;
LINE 064:016** ERROR: Integer expected. Actual type: address
065:     i1 := -p1;
LINE 065:014** ERROR: Integer expected. Actual type: Point
066: 
067:     i1 := i1 + (i1 < i2);
LINE 067:019** ERROR: Integer expected. Actual type: Boolean
068:     i1 := (i1 & i2) + 10;
LINE 068:014** ERROR: Boolean expected. Actual type: integer
LINE 068:019** ERROR: Boolean expected. Actual type: integer
LINE 068:014** ERROR: Integer expected. Actual type: Boolean
069:     i1 := !i1 + 5;
LINE 069:014** ERROR: Boolean expected. Actual type: integer
LINE 069:014** ERROR: Integer expected. Actual type: Boolean
070:     i1 := i1 + i2 * ((i2 + c1) * (i1 * i1));
LINE 070:030** ERROR: Integer expected. Actual type: character
071: 
072:     (* Less Than (<) Expressions *)
073:     b1 := i1 < c1;
LINE 073:018** ERROR: Expected integer, Actual character.
074:     b1 := true < 10;
LINE 074:020** ERROR: Expected Boolean, Actual integer.
075:     b1 := 'a' < false;
LINE 075:022** ERROR: Expected character, Actual Boolean.
076:     b1 := i1 < null;
LINE 076:020** ERROR: Expected integer, Actual address.
077:     b1 := (i1 + 5) < 'z';
LINE 077:025** ERROR: Expected integer, Actual character.
078:     b1 := (i1 < i2) < i1;
LINE 078:025** ERROR: Expected Boolean, Actual integer.
079:     b1 := i1 < (i2 < 10);
LINE 079:019** ERROR: Expected integer, Actual Boolean.
080:     
081:     b1 := p1 < p2;
LINE 081:013** ERROR: Expected Integer, Boolean, or Character. Actual type: Point
082:     b1 := arr1 < arr2;
LINE 082:015** ERROR: Expected Integer, Boolean, or Character. Actual type: IntArray
083:     b1 := func1 < func2;
LINE 083:016** ERROR: Expected Integer, Boolean, or Character. Actual type: int2int
084:     b1 := null < null;
LINE 084:015** ERROR: Expected Integer, Boolean, or Character. Actual type: address
085: 
086:     i1 := i1 < i2;
LINE 086:007** ERROR: Expected integer, Actual Boolean.
087:     c1 := 'a' < 'b';
LINE 087:007** ERROR: Expected character, Actual Boolean.
088:     p1 := 10 < 20;
LINE 088:007** ERROR: Expected Point, Actual Boolean.
089: 
090: 
091:     (* Equal To (=) Expressions *)
092:     b1 := i1 = true;
LINE 092:013** ERROR: Comparison of different types: integer and Boolean
093:     b1 := c1 = 10;
LINE 093:013** ERROR: Comparison of different types: character and integer
094:     b1 := false = 'f';
LINE 094:016** ERROR: Comparison of different types: Boolean and character
095:     b1 := (i1 + i2) = c1;
LINE 095:014** ERROR: Comparison of different types: integer and character
096:     b1 := p1 = i1;
LINE 096:013** ERROR: Comparison of different types: Point and integer
097:     b1 := arr1 = false;
LINE 097:015** ERROR: Comparison of different types: IntArray and Boolean
098:     b1 := c1 = func2;
LINE 098:013** ERROR: Comparison of different types: character and int2int
099: 
100: 
101:     b1 := i1 = null;
LINE 101:013** ERROR: Record or Array expected. Actual: integer
102:     b1 := null = c1;
LINE 102:020** ERROR: Record or Array expected. Actual: character
103:     b1 := true = null;
LINE 103:015** ERROR: Record or Array expected. Actual: Boolean
104:     b1 := p1 = arr1;
LINE 104:013** ERROR: Comparison of different types: Point and IntArray
105:     b1 := arr2 = func1;
LINE 105:015** ERROR: Comparison of different types: IntArray and int2int
106:     b1 := func1 = p2;
LINE 106:016** ERROR: Comparison of different types: int2int and Point
107: 
108:     i1 := i1 = i2;
LINE 108:007** ERROR: Expected integer, Actual Boolean.
109:     p1 := c1 = c2;
LINE 109:007** ERROR: Expected Point, Actual Boolean.
110:     arr1 := null = null;
LINE 110:009** ERROR: Expected IntArray, Actual Boolean.
111: 
112:     b1 := (i1 = i2) = i1;
LINE 112:014** ERROR: Comparison of different types: Boolean and integer
113:     b1 := p1 = (p1 = null);
LINE 113:013** ERROR: Comparison of different types: Point and Boolean
114: 
115:     (* Release/Reserve Expressions *)
116:     i1 := reserve i1;
LINE 116:021** ERROR: Record expected.
LINE 116:007** ERROR: Expected integer, Actual address.
117:     b1 := release b2;
LINE 117:021** ERROR: Address expected. Actual type: Boolean
LINE 117:007** ERROR: Expected Boolean, Actual address.
118:     c1 := reserve c1;
LINE 118:021** ERROR: Record expected.
LINE 118:007** ERROR: Expected character, Actual address.
119:     func1 := reserve func1;
LINE 119:027** ERROR: Variable 'func1' is undefined.
120:     func2 := release func2;
121: 
122:     arr1 := reserve arr1;
LINE 122:025** ERROR: Record expected.
123:     arr1 := reserve arr1(10, 20);
LINE 123:028** ERROR: Expected 1 dimensions. Actual: 2.
124:     arr1 := reserve arr1(true);
LINE 124:030** ERROR: Integer expected. Actual type: Boolean
125:     arr1 := reserve arr1('a');
LINE 125:029** ERROR: Integer expected. Actual type: character
126:     arr1 := reserve arr1(null);
LINE 126:030** ERROR: Integer expected. Actual type: address
127: 
128:     p1 := reserve p1(10);
LINE 128:021** ERROR: Expected array type.
129: 
130:     arr1 := release arr1(10);
LINE 130:025** ERROR: Address expected. Actual type: integer
131:     p1 := release p1(5);
LINE 131:021** ERROR: Array Index or Function Call expected.
132: 
133:     i1 := reserve p1;
LINE 133:007** ERROR: Expected integer, Actual address.
134:     arr1 := p1;
LINE 134:009** ERROR: Expected IntArray, Actual Point.
135:     b1 := reserve arr2(10);
LINE 135:007** ERROR: Expected Boolean, Actual address.
136: }
