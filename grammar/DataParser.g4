parser grammar DataParser;
options {
    tokenVocab = DataLexer;
}

// a simple rule to test if parser generation works. Will be replaced in a future commit.
test: ANY;
