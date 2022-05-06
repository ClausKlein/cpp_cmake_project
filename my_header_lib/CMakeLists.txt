add_library(my_header_lib INTERFACE)
target_link_libraries(my_header_lib INTERFACE project_options project_warnings) # link project_options/warnings

if(NOT DEFINED CMAKE_INSTALL_INCLUDEDIR)
  include(GNUInstallDirs)
endif()

# because the headers has to be installed, it must be an absolute path as a cashed variable!
set(my_header_lib_INCLUDE_DIR
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
    CACHE PATH "")
# Includes
target_include_directories(my_header_lib INTERFACE "$<BUILD_INTERFACE:${my_header_lib_INCLUDE_DIR}>"
                                                   "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")

# Find dependencies:
# because this variable is used by package_project() it has to be set in cache!
set(my_header_lib_DEPENDENCIES_CONFIGURED
    fmt
    CACHE STRING "")

foreach(DEPENDENCY ${my_header_lib_DEPENDENCIES_CONFIGURED})
  find_package(${DEPENDENCY} CONFIG REQUIRED)
endforeach()

# Link dependencies:
target_link_system_libraries(my_header_lib INTERFACE fmt::fmt-header-only)

if(FEATURE_TESTS)
  add_subdirectory("test")
endif()
