package rs.ac.bg.etf.pp1;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

import java_cup.runtime.Symbol;
import rs.ac.bg.etf.pp1.ast.Program;
import rs.etf.pp1.symboltable.Tab;

public class SemanticTest {

	public static void main(String[] args) throws Exception
	{
		if (args.length < 1) {
			System.err.println("Not enough arguments supplied! Usage: SemanticTest <source-file>");
			return;
		}

		File sourceCode = new File(args[0]);
		if (!sourceCode.exists() || !sourceCode.isFile()) {
			System.err.println("Source file [" + sourceCode.getAbsolutePath() + "] not found!");
			return;
		}

		System.out.println("Semantic analysis of source file: " + sourceCode.getAbsolutePath());

		try (BufferedReader br = new BufferedReader(new FileReader(sourceCode))) {
			Yylex lexer = new Yylex(br);
			MJParser p = new MJParser(lexer);
			Symbol parseResult = p.parse();

			if (p.errorDetected) {
				System.err.println("Semantic analysis skipped due to parse errors.");
				return;
			}

			Program prog = (Program) parseResult.value;
			Tab.init();
			SemanticAnalyzer analyzer = new SemanticAnalyzer();
			prog.traverseBottomUp(analyzer);
			System.out.println("Semantic analysis completed.");
		} catch (Exception e) {
			System.err.println("Semantic analysis failed with exception: " + e.getMessage());
			throw e;
		}
	}
}
