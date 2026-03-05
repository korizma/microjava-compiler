package rs.ac.bg.etf.pp1;

import java_cup.runtime.Symbol;

%%

%{

	// ukljucivanje informacije o poziciji tokena
	private Symbol new_symbol(int type) {
		return new Symbol(type, yyline+1, yycolumn);
	}
	
	// ukljucivanje informacije o poziciji tokena
	private Symbol new_symbol(int type, Object value) {
		return new Symbol(type, yyline+1, yycolumn, value);
	}

	private StringBuilder stringLiteral = new StringBuilder();

%}

%cup
%line
%column

%xstate COMMENT
%xstate IN_STRING

%eofval{
	return new_symbol(sym.EOF);
%eofval}

StringChar = [^\r\n\"\\]

%%

" " 							{ }
"\b" 							{ }
"\t" 							{ }
"\r\n" 							{ }
"\n" 							{ }
"\r" 							{ }
"\f" 							{ }

"program"   					{ return new_symbol(sym.PROG); }
"print" 						{ return new_symbol(sym.PRINT); }
"ord" 							{ return new_symbol(sym.ORD); }
"chr" 							{ return new_symbol(sym.CHR); }
"len" 							{ return new_symbol(sym.LEN); }
"return" 						{ return new_symbol(sym.RETURN); }
"length" 						{ return new_symbol(sym.LENGTH); }

"const" 						{ return new_symbol(sym.CONST); }
"static" 						{ return new_symbol(sym.STATIC); }

"abstract" 						{ return new_symbol(sym.ABST); }
"class" 						{ return new_symbol(sym.CLASS); }
"extends" 						{ return new_symbol(sym.EXTEND); }
"this" 							{ return new_symbol(sym.THIS); }
"new" 							{ return new_symbol(sym.NEW); }

"if" 							{ return new_symbol(sym.IF); }
"else" 							{ return new_symbol(sym.ELSE); }
"switch" 						{ return new_symbol(sym.SWITCH); }
"for" 							{ return new_symbol(sym.FOR); }
"continue" 						{ return new_symbol(sym.CONT); }
"break" 						{ return new_symbol(sym.BREAK); }

"void" 							{ return new_symbol(sym.VOID); }
"enum" 							{ return new_symbol(sym.ENUM); }

"+" 							{ return new_symbol(sym.PLUS); }
"-" 							{ return new_symbol(sym.MINUS); }
"=" 							{ return new_symbol(sym.EQUAL); }
"*" 							{ return new_symbol(sym.MUL); }
"/" 							{ return new_symbol(sym.DIV); }
"&" 							{ return new_symbol(sym.AND); }
"|" 							{ return new_symbol(sym.OR); }
"!" 							{ return new_symbol(sym.NOT); }
"%" 							{ return new_symbol(sym.MOD); }

"?" 							{ return new_symbol(sym.QUEST); }
";" 							{ return new_symbol(sym.SEMI); }
":" 							{ return new_symbol(sym.COLON); }
"," 							{ return new_symbol(sym.COMMA); }
"." 							{ return new_symbol(sym.DOT); }
"'" 							{ return new_symbol(sym.SQUOT); }
"<"								{ return new_symbol(sym.LSTHAN); }
">"								{ return new_symbol(sym.GRTHAN); }

"(" 							{ return new_symbol(sym.LPAREN); }
")" 							{ return new_symbol(sym.RPAREN); }
"{" 							{ return new_symbol(sym.LBRACE); }
"}"								{ return new_symbol(sym.RBRACE); }
"[" 							{ return new_symbol(sym.LBRACK); }
"]" 							{ return new_symbol(sym.RBRACK); }

<YYINITIAL> "//" 		     	{ yybegin(COMMENT); }
<COMMENT> .      				{ yybegin(COMMENT); }
<COMMENT> "\r\n" 				{ yybegin(YYINITIAL); }
<COMMENT> "\n" 					{ yybegin(YYINITIAL); }
<COMMENT> "\r" 					{ yybegin(YYINITIAL); }

<YYINITIAL> \"					{ stringLiteral.setLength(0); yybegin(IN_STRING); }
<IN_STRING> {StringChar}+		{ stringLiteral.append(yytext()); }
<IN_STRING> \\\"				{ stringLiteral.append('\"'); }
<IN_STRING> \"					{ yybegin(YYINITIAL); return new_symbol(sym.STRING, stringLiteral.toString()); }
<IN_STRING> "\r\n"				{ yybegin(YYINITIAL); System.err.println("Leksicka greska (nedozvoljen novi red u stringu) u liniji "+(yyline+1)); }
<IN_STRING> "\n"				{ yybegin(YYINITIAL); System.err.println("Leksicka greska (nedozvoljen novi red u stringu) u liniji "+(yyline+1)); }
<IN_STRING> "\r"				{ yybegin(YYINITIAL); System.err.println("Leksicka greska (nedozvoljen novi red u stringu) u liniji "+(yyline+1)); }

[0-9]+  						{ return new_symbol(sym.NUMBER, new Integer (yytext())); }
([a-z]|[A-Z])[a-zA-Z0-9_]* 	{ return new_symbol (sym.IDENT, yytext()); }

. { System.err.println("\nLeksicka greska ("+yytext()+") u liniji "+(yyline+1) + ", u koloni " + yycolumn + "\n"); }






