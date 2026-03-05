package rs.ac.bg.etf.pp1;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

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
			p.parse();
			System.out.println("Parsing completed successfully!");
		}
		catch (Exception e) {
			System.err.println("Parsing failed with exception: " + e.getMessage());
			throw e;
		}
	}
}
