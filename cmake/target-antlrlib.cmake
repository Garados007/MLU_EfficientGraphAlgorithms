# creates the target antlrlib
# requires: antlr4_static

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/third-party/antlr4/runtime/Cpp/cmake)

set(ANTLR4_JAR_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/third-party/antlr-4.13.1-complete.jar)
set(ANTLR_EXECUTABLE ${CMAKE_CURRENT_SOURCE_DIR}/third-party/antlr-4.13.1-complete.jar)

set(ANTLR4_WITH_STATIC_CRT ON)
find_package(ANTLR REQUIRED)

# generate lexer
ANTLR_TARGET(ega_lexer "${CMAKE_CURRENT_SOURCE_DIR}/grammar/DataLexer.g4"
             PACKAGE "ega::grammar"
             DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/grammar/DataLexer.g4"
             LEXER
             )

 # generate parser
ANTLR_TARGET(ega_parser "${CMAKE_CURRENT_SOURCE_DIR}/grammar/DataParser.g4"
             PACKAGE "ega::grammar"
             COMPILE_FLAGS "-lib;${ANTLR_ega_lexer_OUTPUT_DIR}"
             DEPENDS_ANTLR ega_lexer
             DEPENDS "${ANTLR_ega_lexer_OUTPUTS};${CMAKE_CURRENT_SOURCE_DIR}/grammar/DataParser.g4"
             PARSER LISTENER VISITOR
             )

source_group(TREE ${ANTLR4_GENERATED_SRC_DIR}/ega_lexer
             PREFIX ega/grammar
             FILES ${ANTLR4_SRC_FILES_ega_lexer})

source_group(TREE ${ANTLR4_GENERATED_SRC_DIR}/ega_parser
             PREFIX ega/grammar
             FILES ${ANTLR4_SRC_FILES_ega_parser})

set_source_files_properties(${ANTLR_ega_parser_OUTPUT_DIR}/DataParser.cpp PROPERTIES COMPILE_FLAGS $<$<CXX_COMPILER_ID:MSVC>:/wd4100>$<$<CXX_COMPILER_ID:GNU>:-Wno-unused-parameter>)

add_library(antlrlib OBJECT ${ANTLR_ega_lexer_CXX_OUTPUTS} ${ANTLR_ega_parser_CXX_OUTPUTS})
target_link_libraries(antlrlib PUBLIC antlr4_static)
target_include_directories(antlrlib SYSTEM PUBLIC
  ${ANTLR4_INCLUDE_DIRS} ${ANTLR_ega_lexer_OUTPUT_DIR} ${ANTLR_ega_parser_OUTPUT_DIR})

# file(CHMOD ${ANTLR_ega_lexer_OUTPUTS} PERMISSIONS OWNER_WRITE)
# file(CHMOD ${ANTLR_ega_parser_OUTPUTS} PERMISSIONS OWNER_WRITE)
