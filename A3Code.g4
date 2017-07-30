grammar A3Code;

//---------------------------------------------------------------------------------------------------
// Session 1: ANTLR API, You SHOULD NOT make any modification to this session
//---------------------------------------------------------------------------------------------------
@header {

import java.io.*;
}



@parser::members {

public enum DataType {
	INT, BOOLEAN, CHAR, STRING, VOID, INVALID;

    public int getSize() {
        if(this == DataType.INT) {
            return 4;
        } else if(this == DataType.BOOLEAN) {
            return 4;
        } else {
            return 0;
        }
    }
}

int global_scope = 0; // annotatable

public class Scope {

    int scope; // annotatable
    Scope parent;

    Scope () {
        scope = ++global_scope; // annotatable
        parent = null;
    }

    Scope (Scope pr) {
        scope = ++global_scope; // annotatable
        parent = pr;
    }

    Scope getParent() {
        return parent;
    }

    int getScope() { // annotatable
        return scope;
    }

    boolean isAncestor(Scope sc) {
        for (Scope i = this; i != null; i = i.getParent()) {
            if (i.equals(sc)) {
                return true;
            }
        }
        return false;
    }

}

Scope csc = new Scope();


public class Symbol {
	
	String name;
	DataType dt;
    Scope scope;

	Symbol (String n, DataType d, Scope sc) {
		name = n;
		dt = d;
        scope = sc;
	}

	Symbol (int id, DataType d, Scope sc) {
		name = "t_" + id;
		dt = d;
        scope = sc;
	}

	boolean Equal (String n) {
		return (name.equals(n));
	}

	DataType GetType () {
		return dt;
	}

	String GetName () {
		return name;
	}

	void Print() {
		System.out.println(name + "\t" + dt + "\t" + scope.getScope()); // part annotatable
	}
}

public class SymTab {
	
	Symbol st[];
	int size;
	int temps;

	SymTab () {
		st = new Symbol[1000];
		size = 0;
		temps = 0;
	}

	int Find (String n, Scope scope) { // looks for the identifier from all scopes
		for (int  i = size - 1; i >= 0; i --) {
			if (scope.isAncestor(st[i].scope) && st[i].Equal(n))
                return i;
		}
		
		return -1;
	}

	int insert(String n, DataType d, Scope scope) {
		st[size] = new Symbol(n, d, scope);
		return (size ++);
	}

    int insert(int n, Scope scope) {
        Scope sc;
        for (int i = 0; i < size; ++i) {
            if (st[i].Equal(String.valueOf(n)))
                return i;
        }
        for (sc = scope; sc.getParent() != null; sc = sc.getParent());
        st[size] = new Symbol(String.valueOf(n), DataType.INT, sc);
        return (size ++);
    }

	int Add (DataType d, Scope scope) {
		st[size] = new Symbol (temps, d, scope);
		temps ++;
		return (size ++);
	}

	DataType GetType (int id) {
		if (id == -1) return DataType.INVALID;
		return (st[id].GetType());
	}

	String GetName (int id) {
		if (id == -1) return ("");
		return (st[id].GetName()); 
	}

	void Print() {
		for (int  i = 0; i < size; i ++) {
			st[i].Print();
		}
	}

}

SymTab s = new SymTab();


public class Quad {

	String label;
	String op;
	int src1;
	int src2;
	int dst;
    String out;

    Quad (Quad q) {
        label = q.label;
        op = q.op;
        src1 = q.src1;
        src2 = q.src2;
        dst = q.dst;
        out = q.out;
    }

	Quad (int l, int d, int s1, int s2, String o) {
		label = "L_" + String.valueOf(l);
		dst = d;
		src1 = s1;
		src2 = s2;
		op = o;
        //String dstop;

        if(o.equals("param")) {
            //dstop = "";
		    out = label + ": " + s.GetName(dst) + s.GetName(src1) + " " + op + " " + s.GetName(src2);
        } else if (o.equals("goto")) {
            //dstop = "";
            if (src1 == -1) {
		        out = label + ": " + op + " L_";
            } else if (dst == -1 ) {
		        out = label + ": if " + s.GetName(src1) + " " + op + " L_";
            } else {
		        out = label + ": ifFalse " + s.GetName(src1) + " " + op + " L_";
            }
        } else {
            //dstop = " = ";
		    out = label + ": " + s.GetName(dst) + " = " + s.GetName(src1) + " " + op + " " + s.GetName(src2);
        }
	}

	Quad (String l) {
		label = l;
        op = "";
        out = label + ":";
	}

    void appendOut(String ap) {
        out += ap;
    }

	void Print () {
		System.out.println(out);
	}

}

public class QuadTab {

	Quad qt[];
	int size;
    int maxId;

	QuadTab () {
		qt = new Quad[1000];
		size = 0;
        maxId = -1;
	}

	int Add(int dst, int src1, int src2, String op) {
			
		qt[size] = new Quad(size, dst, src1, src2, op);
		return (size ++);
	}
    
    int Add(String fn) {
        qt[size] = new Quad(fn);
        return (size ++);
    }

    // for adding dummy instruction only
    int Add(int label) {
        qt[size] = new Quad("L_" + String.valueOf(label));
        return size ++;
    }

    void backPatch(MyList l, int src) {
        for (int i = 0; i < l.size; ++i) {
            qt[l.list[i]].src2 = src;
            maxInstId(src);
        }
    }

    void maxInstId (int id) {
        if (id > maxId) {
            maxId = id;
        }
    }

    int getSize() {
        return size;
    }

	void Print() {
		for (int  i = 0; i < size; i ++) {
            if (qt[i].op.equals("goto")) {
                qt[i].appendOut(String.valueOf(qt[i].src2));
            }
			qt[i].Print();
		}
	}


}



QuadTab q = new QuadTab();

public class MyList {

    int list[];
    int size;
    
    MyList () {
        list = new int[100];
        size = 0;
    }

    MyList (int instId) {
        list = new int[100];
        size = 0;
        list[ size ++ ] = instId;
    }

    MyList (MyList l) {
        list = new int[100];
        size = l.size;
        for (int i = 0; i < size; ++i) {
            list[i] = l.list[i];
        }
    }

    void shift(int s) {
        for (int i = 0; i < size; ++i) {
            list[i] += s;
        }
    }

    void insert(int id) {
        list[size ++] = id;
    }

    MyList merge(MyList l) {
        for (int i = 0; i < l.size; ++i) {
            list[i + size] = l.list[i];
        }
        size = size + l.size;
        return this;
    }

}

}



//---------------------------------------------------------------------------------------------------
// Session 2: Fill your code here
//---------------------------------------------------------------------------------------------------
prog
: Class Program '{' field_decls method_decls '}'
{
    if (q.maxId == q.size) {
        q.Add(q.maxId);
    }
	s.Print();
	System.out.println("------------------------------------");
	//System.out.println(String.valueOf(q.maxId) + " " + String.valueOf(q.size));
	q.Print();
}
;

field_decls 
: f=field_decls field_decl ';'
| f=field_decls inited_field_decl ';'
| 
;


field_decl returns [DataType t]
: f=field_decl ',' Ident array_loc
{
	$t = $f.t;
	s.insert($Ident.text, $t, csc);
}
| Type Ident array_loc
{
	$t = DataType.valueOf($Type.text.toUpperCase());
	s.insert($Ident.text, $t, csc);
}
;

array_loc
: '[' num ']'
{
}
|
{
}
;

inited_field_decl
: Type Ident '=' literal
{
	
	s.insert($Ident.text, DataType.valueOf($Type.text.toUpperCase()), csc);
}
;

method_decls
: m=method_decls method_decl
{
    csc = new Scope(csc.getParent());
}
|
{
    csc = new Scope(csc);
}
;

method_decl 
: method_sig '(' params ')' block
{
}
| method_sig '(' params ')' block
{
}
;

method_sig
: Type Ident
{
	s.insert($Ident.text, DataType.valueOf($Type.text.toUpperCase()), csc.getParent());
    q.Add($Ident.text);
}
| Void Ident
{
	s.insert($Ident.text, DataType.VOID, csc.getParent());
    q.Add($Ident.text);
}
;

params
: Type Ident nextParams
{
    s.insert($Ident.text, DataType.valueOf($Type.text.toUpperCase()), csc);
}
|
{
}
;

nextParams
: n=nextParams ',' Type Ident
{
    s.insert($Ident.text, DataType.valueOf($Type.text.toUpperCase()), csc);
}
|
{
}
;


block returns [MyList brk, MyList ctn]
: '{' v=var_decls s=statements '}'
{
    csc = csc.getParent();
    $brk = $s.brk;
    $ctn = $s.ctn;
}
;

var_decls
: v=var_decls var_decl ';'
| 
{
    csc = new Scope(csc);
}
;


var_decl returns [DataType t]
: v=var_decl ',' Ident
{
	$t = $v.t;
	s.insert($Ident.text, $t, csc);
}
| Type Ident
{
	$t = DataType.valueOf($Type.text.toUpperCase());
	s.insert($Ident.text, $t, csc);					
}
;

statements returns [MyList brk, MyList ctn]
: statement t=statements
{
    $brk = $t.brk.merge($statement.brk);
    $ctn = $t.ctn.merge($statement.ctn);
}
|
{
    $brk = new MyList();
    $ctn = new MyList();
}
;


statement returns [MyList brk, MyList ctn]
: location '=' expr ';'
{
	q.Add($location.id, $expr.id, -1, "");
    $brk = new MyList();
    $ctn = new MyList();
}
| location '+=' expr ';'
{
    int tmp = s.Add(s.GetType($location.id), csc);
    q.Add(tmp, $location.id, $expr.id, "+");
    q.Add($location.id, tmp, -1, "");
    $brk = new MyList();
    $ctn = new MyList();
}
| location '-=' expr ';'
{
    int tmp = s.Add(s.GetType($location.id), csc);
    q.Add(tmp, $location.id, $expr.id, "-");
    q.Add($location.id, tmp, -1, "");
    $brk = new MyList();
    $ctn = new MyList();
}
| method_call ';'
{
    $brk = new MyList();
    $ctn = new MyList();
}
| If '(' expr ')' marker block
{
    q.backPatch($expr.tlist, $marker.id);
    q.backPatch($expr.flist, q.getSize());
    $brk = $block.brk;
    $ctn = $block.ctn;
}
| If '(' expr ')' m1=marker b1=block uj=unconditional_jump Else m2=marker b2=block
{
    q.backPatch($expr.tlist, $m1.id);
    q.backPatch($expr.flist, $m2.id);
    q.backPatch($uj.nextlist, q.getSize());

    $brk = $block.brk.merge($b2.brk);
    $ctn = $block.ctn.merge($b2.ctn);
}
| For for_init block marker
{
    int tmp = s.Add(DataType.INT, csc);
    int one = s.insert(1, csc);
    q.Add(tmp, $for_init.id, one, "+");
    q.Add(-1, -1, $for_init.mid, "goto");
    
    q.backPatch($block.brk, q.getSize());
    q.backPatch($block.ctn, $marker.id);

    $brk = new MyList();
    $ctn = new MyList();
}
| Ret return_expr ';'
{
    q.Add(-1, $return_expr.id, -1, "ret");
    $brk = new MyList();
    $ctn = new MyList();
}
| Brk ';'
{
    $brk = new MyList(q.Add(-1, -1, -1, "goto"));
    $ctn = new MyList();
}
| Cnt ';'
{
    $brk = new MyList();
    $ctn = new MyList(q.Add(-1, -1, -1, "goto"));
}
| block
{
    $brk = $block.brk;
    $ctn = $block.ctn;
}
;

for_init returns [MyList tlist, MyList flist, int mid, int id]
: Ident '=' e1=expr ',' marker e2=expr
{
    $id = s.insert($Ident.text, DataType.INT, csc);
    q.Add($id, $e1.id, -1, "");
    int tmp = s.Add(DataType.INT, csc);
    q.Add(tmp, $id, $e2.id, "<");
    $tlist = new MyList(q.Add(-1, tmp, -1, "goto"));
    $flist = new MyList(q.Add(0, tmp, -1, "goto"));
    $mid = $marker.id;
}
;

unconditional_jump returns [MyList nextlist]
:
{
    $nextlist = new MyList(q.Add(-1, -1, -1, "goto"));
}
;

method_call returns [int id]
: n=method_name '(' ps=method_params ')'
{
    if (s.GetType(s.Find($n.name, csc)) == DataType.VOID) {
        $id = -1;
    } else {
        $id = s.Add(s.GetType(s.Find($n.name, csc)), csc);
    }
    q.Add($id, s.Find($n.name, csc), s.insert($ps.count, csc), "call");
}
| Callout '(' Str a=callout_args ')'
{
    q.Add(-1, s.insert($Str.text, DataType.STRING, csc), s.insert($a.count, csc), "call");
}
;

method_name returns [String name]
: Ident
{
    $name = $Ident.text;
}
;

method_params returns [int count]
: ps=rest_method_params p=method_param
{
    $count = $ps.count + 1;
}
|
{
    $count = 0;
}
;

method_param
: expr
{
    q.Add(-1, $expr.id, -1, "param");
}
;

rest_method_params returns [int count]
: ps=rest_method_params p=method_param ','
{
    $count = $ps.count + 1;
}
|
{
    $count = 0;
}
;

callout_args returns [int count]
: as=callout_args ',' a=callout_arg
{
    $count = $as.count + 1;
}
|
{
    $count = 0;
}
;

callout_arg
: expr
{
    q.Add(-1, $expr.id, -1, "param");
}
| Str
{
    q.Add(-1, s.insert($Str.text, DataType.STRING, csc), -1, "param");
}
;

return_expr returns [int id]
: expr
{
    $id = $expr.id;
}
|
{
    $id = -1;
}
;

expr returns [int id, MyList tlist, MyList flist]
: e1=expr '||' marker e2=expr
{
    q.backPatch($e1.flist, $marker.id);
    $tlist = $e1.tlist.merge($e2.tlist);
    $flist = $e2.flist;
}
| e=expr7
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
}
;

expr7 returns [int id, MyList tlist, MyList flist]
: e1=expr7 '&&' marker e2=expr7
{
    q.backPatch($e1.tlist, $marker.id);
    $tlist = $e2.tlist;
    $flist = $e1.flist.merge($e2.flist);
}
| e=expr6
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
}
;

expr6 returns [int id, MyList tlist, MyList flist]
: e1=expr6 '==' e2=expr6
{
    $id = s.Add(s.GetType($e1.id), csc);
    q.Add($id, $e1.id, $e2.id, "==");

    $tlist = new MyList (q.Add(-1, $id, -1, "goto"));
    $flist = new MyList (q.Add(0, $id, -1, "goto"));
}
| e1=expr6 '!=' e2=expr6
{
    $id = s.Add(s.GetType($e1.id), csc);
    q.Add($id, $e1.id, $e2.id, "!=");

    $tlist = new MyList (q.Add(-1, $id, -1, "goto"));
    $flist = new MyList (q.Add(0, $id, -1, "goto"));
}
| e=expr5
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
}
;

expr5 returns [int id, MyList tlist, MyList flist]
: e1=expr5 '<' e2=expr5
{
    $id = s.Add(s.GetType($e1.id), csc);
    q.Add($id, $e1.id, $e2.id, "<");

    $tlist = new MyList(q.Add(-1, $id, -1, "goto"));
    $flist = new MyList(q.Add(0, $id, -1, "goto"));
}
| e1=expr5 '<=' e2=expr5
{
    $id = s.Add(s.GetType($e1.id), csc);
    q.Add($id, $e1.id, $e2.id, "<=");

    $tlist = new MyList(q.Add(-1, $id, -1, "goto"));
    $flist = new MyList(q.Add(0, $id, -1, "goto"));
}
| e1=expr5 '>' e2=expr5
{
    $id = s.Add(s.GetType($e1.id), csc);
    q.Add($id, $e1.id, $e2.id, ">");

    $tlist = new MyList (q.Add(-1, $id, -1, "goto"));
    $flist = new MyList(q.Add(0, $id, -1, "goto"));
}
| e1=expr5 '>=' e2=expr5
{
    $id = s.Add(s.GetType($e1.id), csc);
    q.Add($id, $e1.id, $e2.id, ">=");

    $tlist = new MyList(q.Add(-1, $id, -1, "goto"));
    $flist = new MyList(q.Add(0, $id, -1, "goto"));
}
| e=expr4
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
}
;

expr4 returns [int id, MyList tlist, MyList flist]
: e1=expr4 '+' e2=expr4
{
    $id = s.Add(s.GetType($e1.id), csc);
    q.Add($id, $e1.id, $e2.id, "+");
}
| e1=expr4 '-' e2=expr4
{
    $id = s.Add(s.GetType($e1.id), csc);
    q.Add($id, $e1.id, $e2.id, "-");
}
| e=expr3
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
}
;

expr3 returns [int id, MyList tlist, MyList flist]
: e1=expr3 '*' e2=expr3
{
    $id = s.Add(s.GetType($e1.id), csc);
    q.Add($id, $e1.id, $e2.id, "*");
}
| e1=expr3 '/' e2=expr3
{
    $id = s.Add(s.GetType($e1.id), csc);
    q.Add($id, $e1.id, $e2.id, "/");
}
| e1=expr3 '%' e2=expr3
{
    $id = s.Add(s.GetType($e1.id), csc);
    q.Add($id, $e1.id, $e2.id, "%");
}
| e=expr2
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
}
;

expr2 returns [int id, MyList tlist, MyList flist]
: '-' e2=expr2
{
    $id = s.Add(s.GetType($e2.id), csc);
    int zero = s.insert(0, csc);
    q.Add($id, zero, $e2.id, "-");
}
| '!' e2=expr2
{
    $tlist = $e2.flist;
    $flist = $e2.tlist;
}
| e=expr1
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
}
;

expr1 returns [int id, MyList tlist, MyList flist]
: '(' e=expr ')'
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
}
| location
{
    $id = $location.id;
}
| method_call
{
    $id = $method_call.id;
}
| intLiteral
{
    $id = $intLiteral.id;
}
| boolLit
{
    $id = $boolLit.id;
    $tlist = $boolLit.tlist;
    $flist = $boolLit.flist;
}
;

marker returns [int id]
:
{
    $id = q.getSize();
}
;

location returns [int id]
:Ident
{
	$id = s.Find($Ident.text, csc);
    //System.out.println("xxx  " + $Ident.text + " " + String.valueOf($id));
}
| Ident '[' expr ']'
{
    DataType type = s.GetType(s.Find($Ident.text, csc));
    int size = s.insert(type.getSize(), csc); 
    int t = s.Add(DataType.INT, csc);
    q.Add(t, size, $expr.id, "*");
    $id = s.insert($Ident.text + " [ " + s.GetName(t) + " ]", type, csc);
}
;

literal
: boolLit
| intLiteral
;

boolLit returns [int id, MyList tlist, MyList flist]
: 'true'
{
    $id = s.insert("true", DataType.BOOLEAN, csc);
    $tlist = new MyList(q.Add(-1, -1, -1, "goto"));
    $flist = new MyList();

}
| 'false'
{
    $id = s.insert("false", DataType.BOOLEAN, csc);
    $flist = new MyList(q.Add(-1, -1, -1, "goto"));
    $flist = new MyList();
}
;

num
: DecNum
| HexNum
;

intLiteral returns [int id]
: DecNum
{
	$id = s.insert(Integer.parseInt($DecNum.text), csc);
}
| HexNum
{
    $id = s.insert($HexNum.text, DataType.INT, csc);
}
;

// maybe missing char and string
//--------------------------------------------- END OF SESSION 2 -----------------------------------


//---------------------------------------------------------------------------------------------------
// Session 3: Lexical definition, You SHOULD NOT make any modification to this session
//---------------------------------------------------------------------------------------------------
fragment Delim
: ' '
| '\t'
| '\n'
;

fragment Letter
: [a-zA-Z]
;

fragment Digit
: [0-9]
;

fragment HexDigit
: Digit
| [a-f]
| [A-F]
;

fragment Alpha
: Letter
| '_'
;

fragment AlphaNum
: Alpha
| Digit
;

WhiteSpace
: Delim+ -> skip
;

Char
: '\'' ~('\\') '\''
| '\'\\' . '\'' 
;

Str
:'"' ((~('\\' | '"')) | ('\\'.))* '"'
; 

Class
: 'class'
;

Program
: 'Program'
;

Void
: 'void'
;

If
: 'if'
;

Else
: 'else'
;

For
: 'for'
;

Ret
: 'return'
;

Brk
: 'break'
;

Cnt
: 'continue'
;

Callout
: 'callout'
;

DecNum
: Digit+
;

HexNum
: '0x'HexDigit+
;

Type
: 'int'
| 'boolean'
;

Ident
: Alpha AlphaNum* 
;
