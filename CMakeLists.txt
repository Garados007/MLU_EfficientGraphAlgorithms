cmake_minimum_required(VERSION 3.25..3.27 FATAL_ERROR)

project(ega LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_BUILD_TYPE)
  message(STATUS "Using CMAKE_BUILD_TYPE=Release as default")
  set(CMAKE_BUILD_TYPE Release)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/third-party/cmake/CreateLaunchers/cmake")
include(CreateLaunchers)

if(WIN32)
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
  set(LAUNCHPATH "$(ProjectDir)$(Configuration)\\\\$(SolutionName).exe")
  set(LAUNCHARGS "scc $(ProjectDir)..\\\\test.gr")
endif()

if(NOT APPLE)
  include(CheckIncludeFileCXX)
  CHECK_INCLUDE_FILE_CXX("source_location" HEADER_SOURCE_LOCATION)
endif()

if(NOT HEADER_SOURCE_LOCATION)
  message(FATAL_ERROR "The header file <source_location> could not be found.")
endif()

set(SOURCES_WITHOUT_MAIN)
set(HEADERS_WITHOUT_MAIN)
set(SOURCES_TEST)
set(HEADERS_TEST)
set(TEST_SUITES)
add_subdirectory(src)
add_subdirectory(test)
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/src
             FILES ${SOURCES_WITHOUT_MAIN} ${HEADERS_WITHOUT_MAIN})
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR}/test
             FILES ${SOURCES_TEST} ${HEADERS_TEST})

list(APPEND SOURCES_WITHOUT_MAIN
            src/git_version.cpp)

set(SOURCES
    ${SOURCES_WITHOUT_MAIN}
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
    )

set(HEADERS
    ${HEADERS_WITHOUT_MAIN}
    )

include(target-antlr4-static)
include(target-antlrlib)

find_package(Git QUIET REQUIRED)

execute_process(COMMAND "${GIT_EXECUTABLE}" describe --tags --always HEAD
                WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                OUTPUT_VARIABLE GIT_REVISION
                ERROR_QUIET
                OUTPUT_STRIP_TRAILING_WHITESPACE)

# get a semver compatible version string
string(REGEX REPLACE "^v" "" GIT_REVISION "${GIT_REVISION}") # remove "v" prefix
string(REGEX REPLACE "-([0-9]+)-" ".\\1+" GIT_REVISION "${GIT_REVISION}") # fix patches
string(REGEX REPLACE "^([0-9]+.[0-9]+)$" "\\1.0" GIT_REVISION "${GIT_REVISION}") # fix releases

string(TIMESTAMP BUILD_YEAR "%Y")

configure_file(src/git_version.cpp.in src/git_version.cpp @ONLY)

option(EGA_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" OFF)

if(EGA_WARNINGS_AS_ERRORS)
  add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/analyze;/analyze:external-;/external:I${CMAKE_CURRENT_SOURCE_DIR}/third-party;/WX;/W4>$<$<CXX_COMPILER_ID:GNU>:-Werror;-Wall;-Wno-unknown-pragmas;-Wextra;-Wformat;-Werror=format-security;-pedantic>")
endif()

add_compile_options("$<$<CXX_COMPILER_ID:MSVC>:/MP;/Zi>")

set(CPP_STD_HEADERS
    # keep sorted
    <algorithm>
    <array>
    <cstdio>
    <cstdlib>
    <errno.h>
    <functional>
    <initializer_list>
    <iostream>
    <memory>
    <mutex>
    <optional>
    <ostream>
    <regex>
    <set>
    <source_location>
    <sstream>
    <streambuf>
    <string>
    <string_view>
    <tuple>
    <unordered_set>
    <utility>
    <variant>
    <vector>)

add_library(egalib OBJECT ${SOURCES_WITHOUT_MAIN} ${HEADERS})
target_include_directories(egalib SYSTEM PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/third-party/fmt/include
    ${CMAKE_CURRENT_SOURCE_DIR}/third-party/thread-pool/include
    )
target_include_directories(egalib PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${PROJECT_BINARY_DIR}
    )
target_link_libraries(egalib PUBLIC antlrlib)

# needs to be here to avoid a crash
target_compile_definitions(egalib PUBLIC "ANTLR4_USE_THREAD_LOCAL_CACHE")

add_subdirectory(third-party/fmt EXCLUDE_FROM_ALL)
target_link_libraries(egalib PUBLIC fmt::fmt-header-only)

# include CLI11
add_subdirectory(third-party/CLI11)
target_link_libraries(egalib PUBLIC CLI11::CLI11)

target_precompile_headers(egalib
                          PRIVATE
                          ${HEADERS_WITHOUT_MAIN}
                          ${CPP_STD_HEADERS}
                          <antlr4-runtime.h>
                          <CLI/CLI.hpp>
                          <fmt/format.h>
                          <fmt/ostream.h>)

include(tool-coverage)

add_executable(ega ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp)
target_link_libraries(ega PRIVATE egalib antlrlib)

set_target_properties(ega
                      PROPERTIES COMPILE_PDB_NAME "ega")

set_target_properties(ega PROPERTIES
                      XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME TRUE)

include(tool-clang-tidy)
include(target-ega-test)

if(NOT CMAKE_EXPORT_COMPILE_COMMANDS)
  if(MSVC)
    create_default_target_launcher(${PROJECT_NAME} COMMAND ${LAUNCHPATH} ARGS ${LAUNCHARGS})
  else()
    create_target_launcher(${PROJECT_NAME} COMMAND ${LAUNCHPATH} ARGS ${LAUNCHARGS})
  endif()
endif()

include(tool-sanitizer)
