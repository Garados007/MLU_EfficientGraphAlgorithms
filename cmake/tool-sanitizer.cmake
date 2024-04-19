# runs clang sanitizer on the resulting binaries

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/third-party/cmake/sanitizers/cmake")
find_package(Sanitizers REQUIRED)

add_sanitizers(ega)
add_sanitizers(ega_test)
