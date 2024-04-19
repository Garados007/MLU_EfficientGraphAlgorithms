option(BUILD_TESTING "Build tests" OFF)
if(NOT BUILD_TESTING)
  return()
endif()

if(WIN32)
  set(LAUNCHPATH "${CMAKE_CTEST_COMMAND}")
  set(LAUNCHARGS "--test-dir ${CMAKE_CURRENT_BINARY_DIR} -C Release --output-on-failure")
endif()

include(CTest)

# Inspired by https://eb2.co/blog/2015/06/driving-boost.test-with-cmake
function(gather_boost_tests SOURCE_FILE_NAME)

    file(READ "${SOURCE_FILE_NAME}" SOURCE_FILE_CONTENTS)
    string(REGEX MATCHALL "BOOST_(AUTO|FIXTURE)_TEST_CASE\\([^,\\)]+"
           FOUND_TESTS ${SOURCE_FILE_CONTENTS})

    list(TRANSFORM FOUND_TESTS REPLACE ".*\\(([^,\\)]+).*" "\\1")

    list(APPEND ALL_TEST_CASES ${FOUND_TESTS})
    set(ALL_TEST_CASES "${ALL_TEST_CASES}" PARENT_SCOPE)
endfunction()

set(Boost_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/third-party/boost_1_85_0/")
set(Boost_NO_BOOST_CMAKE ON)
set(Boost_NO_SYSTEM_PATHS ON)

find_package(Boost REQUIRED)

add_compile_options("-D_GLIBCXX_USE_CXX11_ABI=0")

add_executable(ega_test ${SOURCES_TEST} ${HEADERS_WITHOUT_MAIN} ${HEADERS_TEST})
target_include_directories(ega_test PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  ${CMAKE_CURRENT_SOURCE_DIR}/test)
target_link_libraries(ega_test PUBLIC Boost::headers egalib antlrlib)

# not using REUSE_FROM here as the compile flags are different
target_precompile_headers(ega_test
                          PRIVATE
                          ${HEADERS_WITHOUT_MAIN}
                          ${CPP_STD_HEADERS}
                          <antlr4-runtime.h>
                          <fmt/format.h>)

foreach(TEST_SUITE IN LISTS TEST_SUITES)
  gather_boost_tests("${TEST_SUITE}")
endforeach()

# not using cmake FIXTURES_SETUP/FIXTURES_CLEANUP as these are not called per test case

message(DEBUG "Found test cases: ${ALL_TEST_CASES}")

foreach(TEST_CASE IN LISTS ALL_TEST_CASES)
   add_test(NAME ${TEST_CASE} COMMAND ega_test --log_level=all --logger=JUNIT,message,JU_${TEST_CASE}.xml:HRF,message,stdout --run_test=*/${TEST_CASE} --catch_system_error=yes)
endforeach()

add_dependencies(ega_test ega)
