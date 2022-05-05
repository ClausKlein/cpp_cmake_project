# Notes:
# - list all the task under PHONY
.PHONY: build test install test_release docs format clean

# see https://cmake.org/cmake/help/latest/manual/cmake-env-variables.7.html
CMAKE_GENERATOR?="Ninja Multi-Config"
export CMAKE_GENERATOR
export CMAKE_EXPORT_COMPILE_COMMANDS=YES
export CTEST_OUTPUT_ON_FAILURE=YES

build:
	cmake -B ./build -G $(CMAKE_GENERATOR) -D CMAKE_BUILD_TYPE:STRING=Release -D FEATURE_TESTS:BOOL=OFF
	cmake --build ./build --config Release

# NOTE: it is important to not export a build with enabled FEATURE_TESTS! CK
install: test_release build
	DESTDIR=${HOME}/.local cmake --build ./build --config Release --target install

test:
	cmake -B ./build -G $(CMAKE_GENERATOR) -D CMAKE_BUILD_TYPE:STRING=Debug -D FEATURE_TESTS:BOOL=ON
	cmake --build ./build --config Debug
	cmake --build ./build --config Debug --target test
	gcovr -r .

test_release:
	cmake -B ./build -G $(CMAKE_GENERATOR) -D CMAKE_BUILD_TYPE:STRING=RelWithDebInfo -D FEATURE_TESTS:BOOL=ON
	cmake --build ./build --config RelWithDebInfo
	cmake --build ./build --config RelWithDebInfo --target test
	gcovr -r .

docs:
	cmake -B ./build -G $(CMAKE_GENERATOR) -D CMAKE_BUILD_TYPE:STRING=Debug -D FEATURE_DOCS:BOOL=ON -D FEATURE_TESTS:BOOL=OFF
	cmake --build ./build --target doxygen-docs --config Debug

format:
	git ls-files --exclude-standard | grep -E '\.(cpp|hpp|c|cc|cxx|hxx|ixx)$$' | xargs clang-format -i -style=file
	git ls-files --exclude-standard | grep -E '(\.cmake|CMakeLists.txt)$$' | xargs cmake-format -i

clean:
	rm -rf ./build
