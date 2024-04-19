# add_subdirectory(name_of_subdir)

list(APPEND HEADERS_WITHOUT_MAIN
     ${CMAKE_CURRENT_SOURCE_DIR}/git_version.hpp
    )

return(PROPAGATE SOURCES_WITHOUT_MAIN HEADERS_WITHOUT_MAIN)
