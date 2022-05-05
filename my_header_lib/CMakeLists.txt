add_library(my_header_lib INTERFACE)
target_link_libraries(my_header_lib INTERFACE project_options project_warnings) # link project_options/warnings

# Includes
set(my_header_lib_INCLUDE_DIR
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
    PARENT_SCOPE)
target_include_directories(my_header_lib INTERFACE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
                                                   "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")

# Find dependencies:
set(my_header_lib_DEPENDENCIES_CONFIGURED fmt) # FIXME: PARENT_SCOPE)

foreach(DEPENDENCY ${my_header_lib_DEPENDENCIES_CONFIGURED})
  find_package(${DEPENDENCY} CONFIG REQUIRED)
endforeach()

# Link dependencies:
target_link_system_libraries(my_header_lib INTERFACE fmt::fmt-header-only)

if(FEATURE_TESTS)
  add_subdirectory("test")
endif()
