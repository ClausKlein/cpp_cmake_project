cmake_minimum_required(VERSION 3.21...3.24)

# set a default CXX standard for the tools and targets that do not specify them.
# If commented, the latest supported standard for your compiler is automatically set.
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_C_STANDARD 17)

# ---- Add dependencies via CPM ----
# see https://github.com/TheLartians/CPM.cmake for more info
include(CPM.cmake)

# see https://github.com/aminya/project_options for more info
cpmaddpackage("gh:aminya/project_options@0.24.1")
list(APPEND CMAKE_MODULE_PATH ${ProjectOptions_SRC_DIR})

# Define the features of the project
include("Features.cmake")

# install vcpkg dependencies: - should be called before defining project()
run_vcpkg()

# Set the project name and language
project(
  cpp_cmake_project
  VERSION 0.2.0
  DESCRIPTION "example only"
  HOMEPAGE_URL "https://github.com/ClausKlein/cpp_cmake_project"
  LANGUAGES CXX C)

# enable sanitizers and clang-tidy if running the tests
set(ENABLE_CLANG_TIDY OFF)
set(ENABLE_COVERAGE OFF)
set(ENABLE_SANITIZER_ADDRESS OFF)
if(FEATURE_TESTS)
  #XXX set(ENABLE_CLANG_TIDY "ENABLE_CLANG_TIDY")
  set(ENABLE_COVERAGE "ENABLE_COVERAGE")

  if(NOT
     "${CMAKE_SYSTEM_NAME}"
     STREQUAL
     "Windows")
    set(ENABLE_SANITIZER_ADDRESS "ENABLE_SANITIZER_ADDRESS")
    set(ENABLE_SANITIZER_UNDEFINED_BEHAVIOR "ENABLE_SANITIZER_UNDEFINED_BEHAVIOR")
  else()
    # or it is MSVC and has run vcvarsall
    string(FIND "$ENV{PATH}" "$ENV{VSINSTALLDIR}" index_of_vs_install_dir)
    if(MSVC AND "${index_of_vs_install_dir}" STREQUAL "-1")
      set(ENABLE_SANITIZER_ADDRESS "ENABLE_SANITIZER_ADDRESS")
    endif()
  endif()
endif()

if(FEATURE_DOCS)
  set(ENABLE_DOXYGEN "ENABLE_DOXYGEN")
else()
  set(ENABLE_DOXYGEN OFF)
endif()

if(PROJECT_IS_TOP_LEVEL)
  include(GNUInstallDirs) # for CMAKE_INSTALL_INCLUDEDIR
  set(CMAKE_VERIFY_INTERFACE_HEADER_SETS YES)
  set(CMAKE_SKIP_INSTALL_RULES ${FEATURE_TESTS})
else()
  option(CMAKE_SKIP_INSTALL_RULES "Disable install rules" YES)
endif()

# Initialize project_options variable related to this project
# This overwrites `project_options` and sets `project_warnings`
# uncomment to enable the options. Some of them accept one or more inputs:
project_options(
  ENABLE_CACHE
  # ENABLE_CPPCHECK
  ${ENABLE_CLANG_TIDY}
  # ENABLE_INTERPROCEDURAL_OPTIMIZATION
  # ENABLE_NATIVE_OPTIMIZATION
  ${ENABLE_DOXYGEN}
  ${ENABLE_COVERAGE}
  ${ENABLE_SANITIZER_ADDRESS}
  ${ENABLE_SANITIZER_UNDEFINED_BEHAVIOR}
  # ENABLE_SANITIZER_LEAK
  # ENABLE_SANITIZER_THREAD
  # ENABLE_SANITIZER_MEMORY
  # ENABLE_PCH
  # PCH_HEADERS
  # WARNINGS_AS_ERRORS
  # ENABLE_INCLUDE_WHAT_YOU_USE
  # ENABLE_USER_LINKER
  # ENABLE_BUILD_WITH_TIME_TRACE
  # ENABLE_UNITY
)

# use xml reporter if coverage is enabled
if(${ENABLE_COVERAGE})
  set(COVERAGE_ARGS REPORTER xml)
endif()

enable_testing()

add_subdirectory(my_exe)
add_subdirectory(my_lib)
add_subdirectory(my_header_lib)

if(FEATURE_FUZZ_TESTS)
  add_subdirectory(fuzz_test)
endif()

# If MSVC is being used, and ASAN is enabled, we need to set the debugger environment
# so that it behaves well with MSVC's debugger, and we can run the target from visual studio
if(MSVC)
  get_all_targets(all_targets)
  set_target_properties(${all_targets} PROPERTIES VS_DEBUGGER_ENVIRONMENT "PATH=$(VC_ExecutablePath_x64);%PATH%")
endif()

# set the startup project for the "play" button in MSVC
set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT my_exe)

if(CMAKE_SKIP_INSTALL_RULES)
  return()
endif()

# Package the project
package_project(
  TARGETS
  my_exe
  my_lib
  my_header_lib
  #XXX project_options
  #XXX project_warnings
  INTERFACE_DEPENDENCIES_CONFIGURED
  ${my_header_lib_DEPENDENCIES_CONFIGURED}
  INTERFACE_INCLUDES
  ${my_header_lib_INCLUDE_DIR}
  PUBLIC_INCLUDES
  ${my_lib_INCLUDE_DIR})

# Experience shows that explicit package naming can help make it easier to sort
# out potential ABI related issues before they start, while helping you
# track a build to a specific GIT SHA
set(CPACK_PACKAGE_FILE_NAME
    "${CMAKE_PROJECT_NAME}-${CMAKE_PROJECT_VERSION}-${GIT_SHORT_SHA}-${CMAKE_SYSTEM_NAME}-${CMAKE_BUILD_TYPE}-${CMAKE_CXX_COMPILER_ID}-${CMAKE_CXX_COMPILER_VERSION}"
)

include(CPack)
