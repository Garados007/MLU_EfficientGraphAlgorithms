find_program(RUN_CLANG_TIDY NAMES run-clang-tidy-18 run-clang-tidy)

if(RUN_CLANG_TIDY)
  add_custom_target(clang-tidy
                    COMMAND ${RUN_CLANG_TIDY}
                    -fix
                    -p=${CMAKE_CURRENT_BINARY_DIR}
                    -export-fixes=${CMAKE_CURRENT_BINARY_DIR}/clang-tidy-fixes.yaml
                    ${SOURCES} ${HEADERS}
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                    COMMENT "Running clang-tidy" VERBATIM)
endif()
