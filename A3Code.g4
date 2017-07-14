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





public class Symbol {
	
	String name;
	DataType dt;

	Symbol (String n, DataType d) {
		name = n;
		dt = d;
	}

	Symbol (int id, DataType d) {
		name = "t_" + id;
		dt = d;
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
		System.out.println(name + "\t" + dt);
	}

	
	
}

public class SymTab {
	
	Symbol st[];
    //SymTab parent;
	int size;
	int temps;

	SymTab () {
		st = new Symbol[1000];
		size = 0;
		temps = 0;
        //parent = null;
	}

    /*
    SymTab (SymTab parent) {
		st = new Symbol[1000];
		size = 0;
		temps = 0;
        this.parent = parent;
    }
    */

	int Find (String n) {
		for (int  i = 0; i < size; i ++) {
			if (st[i].Equal(n)) return i;
		}
		
		return -1;
	}

	int insert(String n, DataType d) {
		int id = Find(n);
		if (id != -1) return id;
	
		st[size] = new Symbol(n, d);
		return (size ++);
	}

	int Add (DataType d) {
		st [size] = new Symbol (temps, d);
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

    /*
    SymTab getParent() {
        return parent;
    }
    */

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

	Quad (int l, int d, int s1, int s2, String o) {
		label = "L_" + String.valueOf(l);
		dst = d;
		src1 = s1;
		src2 = s2;
		op = o;
        String dstop;
        if(o.equals("param")) {
            dstop = "";
        } else {
            dstop = " = ";
        }
		out = label + ": " + s.GetName(dst) + dstop
				+ s.GetName(src1) + " " + op + " " + s.GetName(src2);
	}

	Quad (String l) {
		label = l;
        out = label + ":";
	}

	void Print () {
		System.out.println(out);
	}

}

public class QuadTab {

	Quad qt[];
	int size;

	QuadTab () {
		qt = new Quad[1000];
		size = 0;
	}

	

	int Add(int dst, int src1, int src2, String op) {
			
		qt[size] = new Quad(size, dst, src1, src2, op);
		return (size ++);
	}

    void insert(String label, int pos) {
        //qt[size] = new Quad(label);
        //return (size ++);
        qt[pos] = new Quad(label);
    }

    int reserve() {
        return size++;
    }

	void Print() {
		for (int  i = 0; i < size; i ++) {
			qt[i].Print();
		}
	}


}



QuadTab q = new QuadTab();
int reserved_position;

}



//---------------------------------------------------------------------------------------------------
// Session 2: Fill your code here
//---------------------------------------------------------------------------------------------------
prog
: Class Program '{' field_decls method_decls '}'
{
	s.Print();
	System.out.println("------------------------------------");
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
	s.insert($Ident.text, $t);
}
| Type Ident array_loc
{
	$t = DataType.valueOf($Type.text.toUpperCase());
	s.insert($Ident.text, $t);					
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
}
|
{
}
;

method_decl 
: Type Ident '('  ')' block_method
{
	s.insert($Ident.text, DataType.valueOf($Type.text.toUpperCase()));
    q.insert($Ident.text, reserved_position);
}
| Void Ident '(' params ')' block_method
{
	s.insert($Ident.text, DataType.VOID);
    q.insert($Ident.text, reserved_position);
}
;

params
: Type Ident nextParams
{
}
|
{
}
;

nextParams
: n=nextParams ',' Type Ident
{
}
|
{
}
;


block 
: '{' var_decls statements '}'
;

block_method
: '{' var_decls_method statements '}'
;

var_decls 
: v=var_decls var_decl ';'
| 
{
}
;


var_decl returns [DataType t]
: v=var_decl ',' Ident
{
	$t = $v.t;
	s.insert($Ident.text, $t);
}
| Type Ident
{
	$t = DataType.valueOf($Type.text.toUpperCase());
	s.insert($Ident.text, $t);					
}
;

var_decls_method
: v=var_decls_method var_decl_method ';'
{
}
|
{
    reserved_position = q.reserve(); 
}
;

var_decl_method returns [DataType t]
: v=var_decl_method ',' Ident
{
	$t = $v.t;
	s.insert($Ident.text, $t);
}
| Type Ident
{
	$t = DataType.valueOf($Type.text.toUpperCase());
	s.insert($Ident.text, $t);					
}
;

statements 
: statement t=statements
|
;


statement 
: location '=' expr ';'
{
	q.Add($location.id, $expr.id, -1, "");
}
| method_call ';'
{
}
| If '(' expr ')' block if_else
{
}
| For Ident '=' e1=expr ',' e2=expr block
{
}
| Ret return_expr ';'
{
    q.Add(-1, $return_expr.id, -1, "ret");
}
| Brk ';'
{
}
| Cnt ';'
{
}
| block
{
}
;

method_call returns [int id]
: n=method_name '(' ps=method_params ')'
{
    if (s.GetType(s.Find($n.name)) == DataType.VOID) {
        $id = -1;
    } else {
        $id = s.Add(s.GetType(s.Find($n.name)));
    }
    q.Add($id, s.Find($n.name), s.insert(String.valueOf($ps.count), DataType.INT), "call");
}
| Callout '(' Str a=callout_args ')'
{
    q.Add(-1, s.insert($Str.text, DataType.STRING), s.insert(String.valueOf($a.count), DataType.INT), "call");
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
    q.Add(-1, s.insert($Str.text, DataType.STRING), -1, "param");
}
;

if_else
: Else block
{
}
|
{
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

expr returns [int id]
: e1=expr '||' e2=expr
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, "||");
}
| e=expr7
{
    $id = $e.id;
}
;

expr7 returns [int id]
: e1=expr7 '&&' e2=expr7
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, "&&");
}
| e=expr6
{
    $id = $e.id;
}
;

expr6 returns [int id]
: e1=expr6 '==' e2=expr6
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, "==");
}
| e1=expr6 '!=' e2=expr6
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, "!=");
}
| e=expr5
{
    $id = $e.id;
}
;

expr5 returns [int id]
: e1=expr5 '<' e2=expr5
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, "<");
}
| e1=expr5 '<=' e2=expr5
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, "<=");
}
| e1=expr5 '>' e2=expr5
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, ">");
}
| e1=expr5 '>=' e2=expr5
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, ">=");
}
| e=expr4
{
    $id = $e.id;
}
;

expr4 returns [int id]
: e1=expr4 '+' e2=expr4
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, "+");
}
| e1=expr4 '-' e2=expr4
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, "-");
}
| e=expr3
{
    $id = $e.id;
}
;

expr3 returns [int id]
: e1=expr3 '*' e2=expr3
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, "*");
}
| e1=expr3 '/' e2=expr3
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, "/");
}
| e1=expr3 '%' e2=expr3
{
    $id = s.Add(s.GetType($e1.id));
    q.Add($id, $e1.id, $e2.id, "%");
}
| e=expr2
{
    $id = $e.id;
}
;

expr2 returns [int id]
: '-' e2=expr2
{
    $id = s.Add(s.GetType($e2.id));
    int zero = s.insert("0", DataType.INT);
    q.Add($id, zero, $e2.id, "-");
    // how to deal with 0? for example, -c is interpreted to 0 - c
}
| '!' e2=expr2
{
    $id = s.Add(s.GetType($e2.id));
    q.Add($id, -1, $e2.id, "!");
    // how to deal with op '!'?
}
| e=expr1
{
    $id = $e.id;
}
;

expr1 returns [int id]
: '(' e=expr ')'
{
    $id = $e.id;
}
| location
{
    $id = $location.id;
}
| method_call
{
    $id = $method_call.id;
}
| literal
{
    $id = $literal.id;
}
;

location returns [int id]
:Ident
{
	$id = s.Find($Ident.text);
}
| Ident '[' expr ']'
{
    DataType type = s.GetType(s.Find($Ident.text));
    int size = s.insert(String.valueOf(type.getSize()), type); 
    int t = s.Add(DataType.INT);
    q.Add(t, size, $expr.id, "*");
    $id = s.insert($Ident.text + " [ " + s.GetName(t) + " ]", type);
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
	$id = s.insert($num.text, DataType.INT);
}
| BoolLit
{
    $id = s.insert($BoolLit.text, DataType.BOOLEAN);
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






