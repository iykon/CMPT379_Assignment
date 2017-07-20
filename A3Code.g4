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
            return 1;
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
        /*
		for (int  i = size - 1; i >= 0; i --) {
			if (scope.equals(st[i].scope) && st[i].Equal(n))
                return i;
		}
        */
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
		st [size] = new Symbol (temps, d, scope);
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

    void shift(int begin, int s) {
        if (begin < 0) return;
        for (int i = size - 1; i >= begin; --i) {
            if (qt[i].op.equals("goto") && qt[i].src2 >= begin) {
                qt[i + s] = new Quad(i + s, qt[i].dst, qt[i].src1, qt[i].src2 + s, qt[i].op);
                maxInstId(qt[i].src2 + s);
            } else {
                qt[i + s] = new Quad(i + s, qt[i].dst, qt[i].src1, qt[i].src2, qt[i].op);
            }
        }
        size = size + s;
    }

	int Add(int dst, int src1, int src2, String op) {
			
		qt[size] = new Quad(size, dst, src1, src2, op);
		return (size ++);
	}

    // for adding dummy instruction only
    int Add(int label) {
        qt[size] = new Quad("L_" + String.valueOf(label));
        return size ++;
    }

    void insert(String label, int pos) {
        //qt[size] = new Quad(label);
        //return (size ++);
        qt[pos] = new Quad(label);
    }

    void insert(int dst, int src1, int src2, String op, int pos) {
        qt[pos] = new Quad(pos, dst, src1, src2, op);
    }

        /*
    int getHeadLoc (int pos) {
        if (qt[pos - 1].op.equals("goto")) {
            return pos - 2;
        }
        return pos - 1;
        while (qt[pos-1].op.equals("goto")) --pos;
        while (!qt[pos-1].op.equals("goto")) --pos;
        return pos;
    }
        */

    void backPatch(int pos, int src) {
        qt[pos].src2 = src;
        maxInstId(src);
    }

    void maxInstId (int id) {
        if (id > maxId) {
            maxId = id;
        }
    }

    int reserve() {
        return size++;
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
int reserved_position;

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
: Type Ident '(' params ')' block_method
{
	s.insert($Ident.text, DataType.valueOf($Type.text.toUpperCase()), csc.getParent());
    q.insert($Ident.text, reserved_position);
}
| Void Ident '(' params ')' block_method
{
	s.insert($Ident.text, DataType.VOID, csc.getParent());
    q.insert($Ident.text, reserved_position);
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


block returns [int begin, int end, MyList brk, MyList ctn]
: '{' v=var_decls s=statements '}'
{
    csc = csc.getParent();
    $begin = $v.begin;
    $end = $s.end;
    $brk = $s.brk;
    $ctn = $s.ctn;
}
;

block_method
: '{' var_decls_method statements '}'
;

var_decls returns [int begin]
: v=var_decls var_decl ';'
| 
{
    csc = new Scope(csc);
    $begin = q.getSize();
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

var_decls_method
: v=var_decls_method var_decl ';'
{
}
|
{
    reserved_position = q.reserve(); 
}
;

/*
var_decl_method returns [DataType t]
: v=var_decl_method ',' Ident
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
*/

statements returns [int end, MyList brk, MyList ctn]
: statement t=statements
{
    $end = $t.end;
    $brk = $t.brk.merge($statement.brk);
    $ctn = $t.ctn.merge($statement.ctn);
}
|
{
    $end = q.getSize();
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
| method_call ';'
{
    $brk = new MyList();
    $ctn = new MyList();
}
| If '(' expr ')' block ie=if_else
{

    if ($ie.begin != -1) { // there is else block
        q.shift($ie.begin, 1);
        $ie.brk.shift(1);
        $ie.ctn.shift(1);
        q.insert(-1, -1, $ie.end + 1, "goto", $ie.begin);
        q.maxInstId($ie.end + 1);

        $ie.begin += 1;
        $ie.end += 1;

    } else { // there is no else block

        $ie.begin = $block.end;
        $ie.end = $block.end;

    }
    
    for (int i = 0; i < $expr.tlist.size; ++i) {
        System.out.println("xx: " + String.valueOf($expr.tlist.list[i]));
        q.backPatch($expr.tlist.list[i], $block.begin);
    }

    for (int i = 0; i < $expr.flist.size; ++i) {
        System.out.println("yy: " + String.valueOf($expr.flist.list[i]));
        q.backPatch($expr.flist.list[i], $ie.begin);
    }

    $brk = $block.brk.merge($ie.brk);
    $ctn = $block.ctn.merge($ie.ctn);
}
| For Ident '=' e1=expr ',' e2=expr block
{
    // add initialization
    if ($e2.flabel < 0) $e2.flabel = $block.begin;
    q.shift($e2.flabel, 1);
	int id = s.insert($Ident.text, DataType.INT, csc);
    //System.out.println("in for: id is " + String.valueOf($e1.id));
    //System.out.println("in for: e1.id is " + String.valueOf($e1.id));
    //System.out.println("in for: e2.flabel is " + String.valueOf($e2.flabel));
    q.insert(id, $e1.id, -1, "", $e2.flabel);
    $e2.flabel ++;
    $block.begin ++;
    $block.end ++;

    // add condition check
    q.shift($block.begin, 3);
    int tmpId= s.Add(DataType.INT, csc);
    q.insert(tmpId, id, $e2.id, "<", $block.begin);
    q.insert(-1, tmpId, -1, "goto", $block.begin + 1);
    q.backPatch($block.begin + 1, $block.begin + 3);
    q.insert(0, tmpId, -1, "goto", $block.begin + 2);
    q.backPatch($block.begin + 2, $block.end + 6);
    tmpId = s.Add(DataType.INT, csc);
    int one = s.insert(1, csc);
    q.Add(tmpId, id, s.insert(1, csc), "+");
    q.Add(id, tmpId, -1, "");
    q.Add(-1, -1, $e2.flabel, "goto");

    $block.brk.shift(4);
    $block.ctn.shift(4);
    for (int i = 0; i < $block.brk.size; ++i) {
        q.backPatch($block.brk.list[i], $block.end + 6);
        //q.insert(-1, -1, $block.end + 6, "goto", $block.brk.list[i]);
    }
    for (int i = 0; i < $block.ctn.size; ++i) {
        q.backPatch($block.ctn.list[i], $block.end + 3);
        //q.insert(-1, -1, $block.end + 3, "goto", $block.ctn.list[i]);
    }

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

method_call returns [int id, int flabel]
: n=method_name '(' ps=method_params ')'
{
    if (s.GetType(s.Find($n.name, csc)) == DataType.VOID) {
        $id = -1;
    } else {
        $id = s.Add(s.GetType(s.Find($n.name, csc)), csc);
    }
    $flabel = q.Add($id, s.Find($n.name, csc), s.insert($ps.count, csc), "call");
}
| Callout '(' Str a=callout_args ')'
{
    $flabel = q.Add(-1, s.insert($Str.text, DataType.STRING, csc), s.insert($a.count, csc), "call");
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

if_else returns [int begin, int end, MyList brk, MyList ctn]
: Else block
{
    $begin = $block.begin;
    $end = $block.end;
    $brk = $block.brk;
    $ctn = $block.ctn;
}
|
{
    $begin = -1;
    $end = -1;
    $brk = new MyList();
    $ctn = new MyList();
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

expr returns [int id, MyList tlist, MyList flist, int flabel]
: e1=expr '||' e2=expr
{
    //$id = s.Add(s.GetType($e1.id), csc);
    //q.Add($id, $e1.id, $e2.id, "||");

    for (int i = 0; i < $e1.flist.size; ++i) {
        q.backPatch($e1.flist.list[i], $e2.flabel);
    }

    $tlist = $e1.tlist.merge($e2.tlist);
    $flist = $e2.flist;
    $flabel = $e1.flabel;
}
| e=expr7
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
    $flabel = $e.flabel;
}
;

expr7 returns [int id, MyList tlist, MyList flist, int flabel]
: e1=expr7 '&&' e2=expr7
{
    //$id = s.Add(s.GetType($e1.id), csc);
    //q.Add($id, $e1.id, $e2.id, "&&");

    for (int i = 0; i < $e1.tlist.size; ++i) {
        q.backPatch($e1.tlist.list[i], $e2.flabel);
    }

    $tlist = $e2.tlist;
    $flist = $e1.flist.merge($e2.flist);
    $flabel = $e1.flabel;
}
| e=expr6
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
    $flabel = $e.flabel;
}
;

expr6 returns [int id, MyList tlist, MyList flist, int flabel]
: e1=expr6 '==' e2=expr6
{
    $id = s.Add(s.GetType($e1.id), csc);
    $flabel = q.Add($id, $e1.id, $e2.id, "==");
    if ($e1.flabel >= 0) {
        $flabel = $e1.flabel;
    }

    $tlist = new MyList (q.getSize());
    q.Add(-1, $id, -1, "goto");

    $flist = new MyList (q.getSize());
    q.Add(0, $id, -1, "goto");
}
| e1=expr6 '!=' e2=expr6
{
    $id = s.Add(s.GetType($e1.id), csc);
    $flabel = q.Add($id, $e1.id, $e2.id, "!=");
    if ($e1.flabel >= 0) {
        $flabel = $e1.flabel;
    }

    $tlist = new MyList (q.getSize());
    q.Add(-1, $id, -1, "goto");

    $flist = new MyList (q.getSize());
    q.Add(0, $id, -1, "goto");
}
| e=expr5
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
    $flabel = $e.flabel;
}
;

expr5 returns [int id, MyList tlist, MyList flist, int flabel]
: e1=expr5 '<' e2=expr5
{
    $id = s.Add(s.GetType($e1.id), csc);
    $flabel = q.Add($id, $e1.id, $e2.id, "<");
    if ($e1.flabel >= 0) {
        $flabel = $e1.flabel;
    }

    $tlist = new MyList(q.getSize());
    q.Add(-1, $id, -1, "goto");

    $flist = new MyList(q.getSize());
    q.Add(0, $id, -1, "goto");
}
| e1=expr5 '<=' e2=expr5
{
    $id = s.Add(s.GetType($e1.id), csc);
    $flabel = q.Add($id, $e1.id, $e2.id, "<=");
    if ($e1.flabel >= 0) {
        $flabel = $e1.flabel;
    }

    $tlist = new MyList(q.getSize());
    q.Add(-1, $id, -1, "goto");

    $flist = new MyList(q.getSize());
    q.Add(0, $id, -1, "goto");
}
| e1=expr5 '>' e2=expr5
{
    $id = s.Add(s.GetType($e1.id), csc);
    $flabel = q.Add($id, $e1.id, $e2.id, ">");
    if ($e1.flabel >= 0) {
        $flabel = $e1.flabel;
    }

    $tlist = new MyList(q.getSize());
    q.Add(-1, $id, -1, "goto");

    $flist = new MyList(q.getSize());
    q.Add(0, $id, -1, "goto");
}
| e1=expr5 '>=' e2=expr5
{
    $id = s.Add(s.GetType($e1.id), csc);
    $flabel = q.Add($id, $e1.id, $e2.id, ">=");
    if ($e1.flabel >= 0) {
        $flabel = $e1.flabel;
    }

    $tlist = new MyList(q.getSize());
    q.Add(-1, $id, -1, "goto");

    $flist = new MyList(q.getSize());
    q.Add(0, $id, -1, "goto");
}
| e=expr4
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
    $flabel = $e.flabel;
}
;

expr4 returns [int id, MyList tlist, MyList flist, int flabel]
: e1=expr4 '+' e2=expr4
{
    $id = s.Add(s.GetType($e1.id), csc);
    $flabel = q.Add($id, $e1.id, $e2.id, "+");
    if ($e1.flabel >= 0) {
        $flabel = $e1.flabel;
    }
}
| e1=expr4 '-' e2=expr4
{
    $id = s.Add(s.GetType($e1.id), csc);
    $flabel = q.Add($id, $e1.id, $e2.id, "-");
    if ($e1.flabel >= 0) {
        $flabel = $e1.flabel;
    }
}
| e=expr3
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
    $flabel = $e.flabel;
}
;

expr3 returns [int id, MyList tlist, MyList flist, int flabel]
: e1=expr3 '*' e2=expr3
{
    $id = s.Add(s.GetType($e1.id), csc);
    $flabel = q.Add($id, $e1.id, $e2.id, "*");
    if ($e1.flabel >= 0) {
        $flabel = $e1.flabel;
    }
}
| e1=expr3 '/' e2=expr3
{
    $id = s.Add(s.GetType($e1.id), csc);
    $flabel = q.Add($id, $e1.id, $e2.id, "/");
    if ($e1.flabel >= 0) {
        $flabel = $e1.flabel;
    }
}
| e1=expr3 '%' e2=expr3
{
    $id = s.Add(s.GetType($e1.id), csc);
    $flabel = q.Add($id, $e1.id, $e2.id, "%");
    if ($e1.flabel >= 0) {
        $flabel = $e1.flabel;
    }
}
| e=expr2
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
    $flabel = $e.flabel;
}
;

expr2 returns [int id, MyList tlist, MyList flist, int flabel]
: '-' e2=expr2
{
    $id = s.Add(s.GetType($e2.id), csc);
    int zero = s.insert(0, csc);
    $flabel = q.Add($id, zero, $e2.id, "-");
    if ($e2.flabel >= 0) {
        $flabel = $e2.flabel;
    }
}
| '!' e2=expr2
{
    /*
    $id = s.Add(s.GetType($e2.id), csc);
    q.Add($id, -1, $e2.id, "!");
    */
    $tlist = $e2.flist;
    $flist = $e2.tlist;
    $flabel = $e2.flabel;
}
| e=expr1
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
    $flabel = $e.flabel;
}
;

expr1 returns [int id, MyList tlist, MyList flist, int flabel]
: '(' e=expr ')'
{
    $id = $e.id;
    $tlist = $e.tlist;
    $flist = $e.flist;
    $flabel = $e.flabel;
}
| location
{
    $id = $location.id;
    $tlist = null;
    $flist = null;
    $flabel = $location.flabel;
}
| method_call
{
    $id = $method_call.id;
    $tlist = null;
    $flist = null;
    $flabel = $method_call.flabel;
}
| literal
{
    $id = $literal.id;
    $tlist = null;
    $flist = null;
    $flabel = -1;
}
;

location returns [int id, int flabel]
:Ident
{
	$id = s.Find($Ident.text, csc);
    $flabel = -1;
    //System.out.println("xxx  " + $Ident.text + " " + String.valueOf($id));
}
| Ident '[' expr ']'
{
    DataType type = s.GetType(s.Find($Ident.text, csc));
    int size = s.insert(type.getSize(), csc); 
    int t = s.Add(DataType.INT, csc);
    $flabel = q.Add(t, size, $expr.id, "*");
    $id = s.insert($Ident.text + " [ " + s.GetName(t) + " ]", type, csc);
}
;


BoolLit
: 'true'
| 'false'
;

num
: DecNum
| HexNum
;

literal returns [int id]
: num
{
	$id = s.insert(Integer.parseInt($num.text), csc);
}
| BoolLit
{
    $id = s.insert($BoolLit.text, DataType.BOOLEAN, csc);
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






