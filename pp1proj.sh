#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Invalid arguments."
    echo "Usage: $0 {lexer|parser|astparser|lexertest|parsertest|astparsertest|semantictest} [source-file]"
    exit 1
fi

if ! java -version 2>&1 | grep -q 'version "1\.8'; then
    echo "Java version is wrong!"
    exit 1
fi

target="$1"
source_file="${2:-}"

if [[ "$target" == "lexertest" || "$target" == "parsertest" || "$target" == "astparsertest" || "$target" == "semantictest" ]]; then
    if [ "$#" -ne 2 ]; then
        echo "Target '$target' requires a source file."
        echo "Usage: $0 $target <source-file>"
        exit 1
    fi

    if [ ! -f "$source_file" ]; then
        echo "Source file not found: $source_file"
        exit 1
    fi
elif [[ "$target" == "lexer" || "$target" == "parser" || "$target" == "astparser" ]]; then
    if [ "$#" -ne 1 ]; then
        echo "Target '$target' does not take a source file."
        echo "Usage: $0 $target"
        exit 1
    fi
fi

clean() 
{
    rm -rf src/rs/ac/bg/etf/pp1/sym.java
    rm -rf src/rs/ac/bg/etf/pp1/Yylex.java
    rm -rf src/rs/ac/bg/etf/pp1/MJParser.java
}

clean_ast()
{
    rm -f src/rs/ac/bg/etf/pp1/ast/*.java
}

compile_lexer() {
    java -jar lib/JFlex.jar -d src/rs/ac/bg/etf/pp1 src/spec/mjlexer.flex
}

compile_parser() {
    java -jar lib/cup_v10k.jar \
        -destdir src/rs/ac/bg/etf/pp1 \
        -parser MJParser \
        -symbols sym \
        src/spec/mjparser.cup
}

compile_parser_ast() {
    local ast_spec_file="${MJ_CUP_AST_SPEC:-spec/mjparser.cup}"
    local ast_spec_abs="$ast_spec_file"
    local temp_ast_spec

    if [[ "$ast_spec_abs" != /* ]]; then
        ast_spec_abs="src/$ast_spec_abs"
    fi

    temp_ast_spec="$(mktemp /tmp/mj_ast_spec.XXXXXX.cup)"
    sed '/^import[[:space:]]\+java_cup\.runtime\.\*;/a\
import rs.ac.bg.etf.pp1.ast.*;
' "$ast_spec_abs" > "$temp_ast_spec"

    mkdir -p src/rs/ac/bg/etf/pp1/ast
    clean_ast
    (
        cd src
        java -jar ../lib/cup_v10k.jar \
            -destdir rs/ac/bg/etf/pp1 \
            -parser MJParser \
            -symbols sym \
            -ast rs.ac.bg.etf.pp1.ast \
            -buildtree \
            "$temp_ast_spec"
    )
    rm -f "$temp_ast_spec"
}

run_lexer_test() {
    # Ensure generated sources exist and are up-to-date.
    compile_parser
    compile_lexer

    mkdir -p out
    javac -cp lib/cup_v10k.jar \
        --release 8 \
        -d out \
        src/rs/ac/bg/etf/pp1/sym.java \
        src/rs/ac/bg/etf/pp1/Yylex.java \
        test/rs/ac/bg/etf/pp1/LexerTest.java

    java -cp out:lib/cup_v10k.jar rs.ac.bg.etf.pp1.LexerTest "$source_file"

    rm -rf out/*
    clean
}

run_parser_test() {
    # Ensure generated sources exist and are up-to-date.
    compile_parser
    compile_lexer

    mkdir -p out
    javac -cp lib/cup_v10k.jar \
        --release 8 \
        -d out \
        src/rs/ac/bg/etf/pp1/sym.java \
        src/rs/ac/bg/etf/pp1/Yylex.java \
        src/rs/ac/bg/etf/pp1/MJParser.java \
        test/rs/ac/bg/etf/pp1/ParserTest.java

    java -cp out:lib/cup_v10k.jar rs.ac.bg.etf.pp1.ParserTest "$source_file"

    rm -rf out/*
    clean
}

run_ast_parser_test() {
    # Ensure generated sources exist and are up-to-date.
    compile_parser_ast
    compile_lexer

    mkdir -p out
    javac -cp lib/cup_v10k.jar:lib/symboltable.jar \
        --release 8 \
        -d out \
        src/rs/ac/bg/etf/pp1/sym.java \
        src/rs/ac/bg/etf/pp1/Yylex.java \
        src/rs/ac/bg/etf/pp1/MJParser.java \
        src/rs/ac/bg/etf/pp1/ast/*.java \
        test/rs/ac/bg/etf/pp1/ParserTest.java

    java -cp out:lib/cup_v10k.jar:lib/symboltable.jar rs.ac.bg.etf.pp1.ParserTest "$source_file"

    rm -rf out/*
    clean
    clean_ast
}

run_semantic_test() {
    # Ensure generated sources exist and are up-to-date.
    compile_parser_ast
    compile_lexer

    local semantic_test_file="test/rs/ac/bg/etf/pp1/SemanticTest.java"
    if [ ! -f "$semantic_test_file" ]; then
        echo "Semantic test class not found: $semantic_test_file"
        echo "Create it first, then rerun: $0 semantictest <source-file>"
        clean
        exit 1
    fi

    mkdir -p out
    javac -cp lib/cup_v10k.jar:lib/symboltable.jar:lib/log4j-1.2.17.jar \
        --release 8 \
        -d out \
        src/rs/ac/bg/etf/pp1/sym.java \
        src/rs/ac/bg/etf/pp1/Yylex.java \
        src/rs/ac/bg/etf/pp1/MJParser.java \
        src/rs/ac/bg/etf/pp1/ast/*.java \
        src/rs/ac/bg/etf/pp1/SemanticAnalyzer.java \
        "$semantic_test_file"


    java -cp out:lib/cup_v10k.jar:lib/symboltable.jar:lib/log4j-1.2.17.jar \
        rs.ac.bg.etf.pp1.SemanticTest "$source_file"

    rm -rf out/*
    clean
}

case "$target" in
    lexer)
        compile_lexer
        ;;
    parser)
        compile_parser
        ;;
    astparser)
        compile_parser_ast
        ;;
    lexertest)
        run_lexer_test
        ;;
    parsertest)
        run_parser_test
        ;;
    astparsertest)
        run_ast_parser_test
        ;;
    semantictest)
        run_semantic_test
        ;;
    *)
        echo "Unknown target: $target"
        echo "Usage: $0 {lexer | parser | astparser | lexertest | parsertest | astparsertest | semantictest}"
        exit 1
        ;;
esac
