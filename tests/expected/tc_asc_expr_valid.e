001: (* Valid Tests for expressions *)
002: 
003: type Point : [integer : x; integer : y; Boolean : b; character : c]
004: type IntArray: 1 -> integer
005: type int2int: integer -> IntArray
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
021:     b1 := true;
022:     b2 := false;
023:     b1 := b2;
024:     b1 := ((b2));
025:     b1 := b1 | b2;
026:     b1 := b1 & b2;
027:     b1 := ((b1 | b2) & (b2 & b2)) & b1 | b2;
028:     b1 := ((true | false | b2) & (b2 & true)) & b1 | false;
029: 
030:     (* Integer Expressions *)
031:     i1 := 10;
032:     i2 := 2023943081;
033:     i1 := -1023;
034:     i2 := 0;
035:     i1 := 0 + i1;
036:     i1 := -10 + i1;
037:     i1 := 10 + 203 - 0 - i2 + i1;
038:     i1 := ((i1));
039:     i1 := -i2;
040:     i1 := -(-i1);
041:     
042:     i1 := i1 + i2;
043:     i1 := i1 - i2;
044:     i1 := i1 * i2;
045:     i1 := i1 / i2;
046:     i1 := i1 % i2;
047:     
048:     i1 := i1 + 100;
049:     i1 := 500 - i2;
050:     i1 := 0 * i1;
051:     i1 := i1 / 1;
052:     i1 := i2 % 10;
053: 
054:     i1 := i1 + i2 * 10;
055:     i1 := i1 * i2 + 10;
056:     i1 := i1 - i2 - 10;
057:     i1 := i1 / i2 * 10;
058:     i1 := 10 + 203 - 0 - i2 + i1;
059:     i1 := -10 + i1 * -5;
060: 
061:     i1 := (i1 + i2) * 10;
062:     i1 := i1 * (i2 + 10);
063:     i1 := (i1 - i2) / (i1 + 1);
064:     i1 := ((i1 % 2) + (i2 * 3)) / 5;
065:     i1 := -((i1 + i2) * 10);
066:     
067:     (* Less Than (<) Expressions *)
068:     b1 := i1 < i2;
069:     b1 := i1 < 100;
070:     b1 := -10 < -5;
071:     b1 := (i1 + i2) < (i1 * 2);
072: 
073:     b1 := i1 < i2;
074:     b1 := i1 < 100;
075:     b1 := 50 < i2;
076:     b1 := -10 < -5;
077:     b1 := -10 < (-5);
078:     b1 := (i1 + i2) < (i1 * 2);
079:     b1 := (i1 % 2) < 1;
080:     b1 := -i1 < (i2 / 4);
081: 
082:     b1 := c1 < c2;
083:     b1 := c1 < 'z';
084:     b1 := 'A' < c2;
085:     b1 := 'a' < 'b';
086: 
087:     b1 := b1 < b2;
088:     b1 := b1 < true;
089:     b1 := false < b2;
090:     b1 := false < true;
091:     b1 := (b1 & b2) < (b1 | true);
092: 
093:     b1 := (i1 < i2) & (c1 < 'z'); 
094:     b1 := (b1 < true) | (i1 < 0);
095:     b1 := ! (i1 < i2);
096: 
097:     (* Equal To (=) Expressions *)
098:     b1 := i1 = i2;
099:     b1 := i1 = 100;
100:     b1 := -10 = -5;
101:     b1 := (i1 + i2) = (i1 * 2);
102: 
103:     b1 := i1 = i2;
104:     b1 := i1 = 100;
105:     b1 := 50 = i2;
106:     b1 := -10 = -5;
107:     b1 := -10 = (-5);
108:     b1 := (i1 + i2) = (i1 * 2);
109:     b1 := (i1 % 2) = 1;
110:     b1 := -i1 = (i2 / 4);
111: 
112:     b1 := c1 = c2;
113:     b1 := c1 = 'z';
114:     b1 := 'A' = c2;
115:     b1 := 'a' = 'b';
116: 
117:     b1 := b1 = b2;
118:     b1 := b1 = true;
119:     b1 := false = b2;
120:     b1 := false = true;
121:     b1 := (b1 & b2) = (b1 | true);
122: 
123:     b1 := (i1 = i2) & (c1 = 'z'); 
124:     b1 := (b1 = true) | (i1 = 0);
125:     b1 := ! (i1 = i2);
126: 
127:     b1 := p1 = p2;
128:     b1 := p1 = null;
129:     b1 := null = p2;
130:     b1 := arr1 = arr2;
131:     b1 := arr1 = null;
132:     b1 := null = arr2;
133: 
134:     b1 := func1(i1) = func2(i1);
135:     b1 := func1(i1) = null;
136:     b1 := null = func2(i1);
137:     b1 := null = null;
138: 
139:     (* Release/Reserve Expressions *)
140:     p1 := reserve p1;
141:     p2 := reserve p2;
142:     p1 := release p1;
143:     p2 := release p2;
144:     p1 := null;
145:     p2 := p1;
146:     
147:     arr1 := reserve arr1(10);
148:     arr2 := reserve arr2(i1 + 5);
149:     arr1 := release arr1;
150:     arr2 := release arr2;
151:     arr1 := null;
152:     arr2 := arr1;
153: 
154:     b1 := (reserve p1) = null;
155:     b1 := (release arr1) = null;
156: }
