add_library(my_lib "src/my_lib/lib.cpp")
target_link_libraries(my_lib PRIVATE project_options project_warnings) # link project_options/warnings

if(NOT DEFINED CMAKE_INSTALL_INCLUDEDIR)
  message(FATAL_ERROR "missing CMAKE_INSTALL_INCLUDEDIR!")
endif()

# Includes
set(my_lib_INCLUDE_DIR
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
    PARENT_SCOPE)
target_include_directories(my_lib PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
                                         "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")

# Find dependencies:
set(my_lib_DEPENDENCIES_CONFIGURED fmt)

foreach(DEPENDENCY ${my_lib_DEPENDENCIES_CONFIGURED})
  find_package(${DEPENDENCY} CONFIG REQUIRED)
endforeach()

# Link dependencies:
target_link_system_libraries(my_lib PRIVATE fmt::fmt)

if(FEATURE_TESTS)
  add_subdirectory("test")
endif()
