001: (* Valid Function Tests *)
002: 
003: type IntOp : integer -> integer
004: type BoolOp : Boolean -> Boolean
005: type HigherOrder : integer -> IntOp
006: type void : integer -> integer
007: type FuncArg : IntOp -> integer
008: 
009: function negate : IntOp
010: function is_positive : BoolOp
011: function get_operator : HigherOrder
012: function apply_func : FuncArg
013: function get_null_op : HigherOrder
014: function entry : void
015: 
016: entry(arg) := {
017:     [
018:         integer : i1; 
019:         Boolean : b1;
020:         IntOp : f_int;
021:         BoolOp : f_bool;
022:         HigherOrder : f_high
023:     ]
024: 
025:     (* Function Assignments *)
026:     f_int := negate;
027:     f_bool := is_positive;
028:     f_high := get_operator;
029:     f_int := null;
030:     f_high := null;
031: 
032:     (* Comparisons with null *)
033:     b1 := f_int = null;
034:     b1 := null = f_bool;
035:     b1 := negate = null;
036:     b1 := get_operator = null;
037: 
038:     (* Function Calls *)
039:     i1 := negate(10);
040:     i1 := f_int(20);
041:     b1 := is_positive(true);
042: 
043:     f_int := get_operator(5);
044:     i1 := get_operator(5)(10);
045:     i1 := f_high(5)(10);
046: 
047:     i1 := negate(i1 + 50 * 2);
048:     i1 := negate(negate(10));
049: 
050:     i1 := apply_func(negate);
051:     i1 := apply_func(null);
052: 
053:     f_int := get_null_op(1);
054: }
055: 
056: negate(x) := {
057:     return -x;
058: }
059: 
060: get_operator(seed) := {
061:     return negate;
062: }
063: 
064: apply_func(func_ptr) := {
065:     return 0;
066: }
067: 
068: get_null_op(seed) := {
069:     return null; 
070: }
