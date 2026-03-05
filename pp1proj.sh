#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Invalid arguments."
    echo "Usage: $0 {lexer|parser|lexertest|parsertest} [source-file]"
    exit 1
fi

if ! java -version 2>&1 | grep -q 'version "1\.8'; then
    echo "Java version is wrong!"
    exit 1
fi

target="$1"
source_file="${2:-}"

if [[ "$target" == "lexertest" || "$target" == "parsertest" ]]; then
    if [ "$#" -ne 2 ]; then
        echo "Target '$target' requires a source file."
        echo "Usage: $0 $target <source-file>"
        exit 1
    fi

    if [ ! -f "$source_file" ]; then
        echo "Source file not found: $source_file"
        exit 1
    fi
elif [[ "$target" == "lexer" || "$target" == "parser" ]]; then
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

case "$target" in
    lexer)
        compile_lexer
        ;;
    parser)
        compile_parser
        ;;
    lexertest)
        run_lexer_test
        ;;
    parsertest)
        run_parser_test
        ;;
    *)
        echo "Unknown target: $target"
        echo "Usage: $0 {lexer | parser | lexertest | parsertest}"
        exit 1
        ;;
esac
