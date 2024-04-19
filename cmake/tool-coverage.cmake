option(EGA_ENABLE_COVERAGE "Instrument code for coverage analysis" OFF)

if(EGA_ENABLE_COVERAGE AND NOT (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang"))
  message(WARNING "Code coverage is not supported for selected compiler.")
  set(EGA_ENABLE_COVERAGE OFF)
endif()

if(EGA_ENABLE_COVERAGE)
  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(egalib PUBLIC --coverage)
    target_link_options(egalib PUBLIC --coverage)
  endif()
endif()
