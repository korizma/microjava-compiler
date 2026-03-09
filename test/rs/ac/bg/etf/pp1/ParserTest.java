package rs.ac.bg.etf.pp1;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.lang.reflect.Method;

import java_cup.runtime.Symbol;

public class ParserTest {

	public static void main(String[] args) throws Exception
	{
		if (args.length < 1) {
			System.err.println("Not enough arguments supplied! Usage: ParserTest <source-file>");
			return;
		}

		File sourceCode = new File(args[0]);
		if (!sourceCode.exists() || !sourceCode.isFile()) {
			System.err.println("Source file [" + sourceCode.getAbsolutePath() + "] not found!");
			return;
		}

		System.out.println("Parsing source file: " + sourceCode.getAbsolutePath());

		try (BufferedReader br = new BufferedReader(new FileReader(sourceCode))) {
			Yylex lexer = new Yylex(br);
			MJParser p = new MJParser(lexer);
			Symbol parseResult = p.parse();
			if (p.errorDetected) 
			{
				System.err.println("Parsing completed with errors!");
			} else 
			{
				printAstIfPossible(parseResult == null ? null : parseResult.value);
				System.out.println("Parsing completed successfully!");
			}
		}
		catch (Exception e) {
			System.err.println("Parsing failed with exception: " + e.getMessage());
			throw e;
		}
	}

	private static void printAstIfPossible(Object parseRoot) {
		if (parseRoot == null) {
			return;
		}
		try {
			Method toStringWithIndent = parseRoot.getClass().getMethod("toString", String.class);
			Object astText = toStringWithIndent.invoke(parseRoot, "");
			if (astText != null) {
				System.out.println(astText.toString());
			}
		} catch (ReflectiveOperationException ignored) {
			// Non-AST grammar/root; nothing to print.
		}
	}
}
