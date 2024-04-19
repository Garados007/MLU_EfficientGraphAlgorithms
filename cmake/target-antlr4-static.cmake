# creates the target antlr4_static

# Setup some variables

if(${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
  set(ANTLR4_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime/runtime/$(Configuration))
elseif(${CMAKE_GENERATOR} MATCHES "Xcode.*")
  set(ANTLR4_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime/runtime/$(CONFIGURATION))
else()
  set(ANTLR4_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime/runtime)
endif()
if(MSVC)
  set(ANTLR4_STATIC_LIBRARIES
      ${ANTLR4_OUTPUT_DIR}/antlr4-runtime-static.lib)
else()
  set(ANTLR4_STATIC_LIBRARIES
      ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.a)
endif()

# build project from git submodule

set(ANTLR4_WITH_STATIC_CRT ON)
include(ExternalProject)
ExternalProject_Add(
  antlr4_runtime
  PREFIX antlr4_runtime
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third-party/antlr4
  SOURCE_SUBDIR runtime/Cpp
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/antlr4_runtime
  # BUILD_COMMAND ""
  INSTALL_COMMAND ""
  TEST_COMMAND ""
  CMAKE_CACHE_ARGS
          -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
          -DWITH_STATIC_CRT:BOOL=${ANTLR4_WITH_STATIC_CRT}
          -DDISABLE_WARNINGS:BOOL=ON
          -DANTLR_BUILD_CPP_TESTS:BOOL=OFF
          -DANTLR_BUILD_SHARED:BOOL=OFF
          -DANTLR4_WITH_STATIC_CRT:BOOL=ON
          -DANTLR4CPP_STATIC:BOOL=ON
)

# set properties and create target

add_library(antlr4_static STATIC IMPORTED)
add_dependencies(antlr4_static antlr4_runtime)
set_target_properties(antlr4_static PROPERTIES
                      IMPORTED_LOCATION ${ANTLR4_STATIC_LIBRARIES})
set_target_properties(antlr4_static PROPERTIES
  INTERFACE_COMPILE_DEFINITIONS "ANTLR4CPP_STATIC"
)
set(ANTLR4_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/third-party/antlr4/runtime/Cpp/runtime/src)
target_include_directories(antlr4_static
  INTERFACE ${ANTLR4_INCLUDE_DIRS}
  )
include_directories(${ANTLR4_INCLUDE_DIRS})
