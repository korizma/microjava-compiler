package rs.ac.bg.etf.pp1;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java_cup.runtime.Symbol;

public class LexerTest 
{
	public static void main(String[] args) throws Exception
	{
		File sourceFile = new File("test/program.mj");
		try (BufferedReader br = new BufferedReader(new FileReader(sourceFile))) {
			Yylex lexer = new Yylex(br);
			while (true) {
				Symbol symbol = lexer.next_token();
				String value = symbol.value == null ? "" : " (" + symbol.value + ")";
				System.out.println("line " + symbol.left + ", col " + symbol.right + ": token " + symbol.sym + value);
				if (symbol.sym == sym.EOF) {
					System.out.println("End of file reached.");
					break;
				}
			}
		}
	}
	
}
