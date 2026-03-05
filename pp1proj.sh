#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Invalid arguments"
    echo "Usage: $0 {lexer|parser|lexertest}"
    exit 1
fi

if ! java -version 2>&1 | grep -q 'version "1\.8'; then
    echo "Java version is wrong!"
    exit 1
fi

target="$1"

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

    java -cp out:lib/cup_v10k.jar rs.ac.bg.etf.pp1.LexerTest

    rm -f out/*
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
    *)
        echo "Unknown target: $target"
        echo "Usage: $0 {lexer|parser|lexertest}"
        exit 1
        ;;
esac
