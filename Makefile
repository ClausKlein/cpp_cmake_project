# Notes:
# - list all the task under PHONY
.PHONY: build test install test_release docs format clean

build:
	cmake ./ -B ./build -G "Ninja Multi-Config" -D CMAKE_BUILD_TYPE:STRING=Release -D FEATURE_TESTS:BOOL=OFF -D FEATURE_DOCS:BOOL=OFF
	cmake --build ./build --config Release

install: test build
	DESTDIR=${HOME}/.local cmake --build ./build --config Release --target install

test:
	cmake ./ -B ./build -G "Ninja Multi-Config" -D CMAKE_BUILD_TYPE:STRING=Debug -D FEATURE_TESTS:BOOL=ON
	cmake --build ./build --config Debug

	(cd build/my_exe/test && ctest -C Debug --output-on-failure)
	(cd build/my_header_lib/test && ctest -C Debug --output-on-failure)
	(cd build/my_lib/test && ctest -C Debug --output-on-failure)

test_release:
	cmake ./ -B ./build -G "Ninja Multi-Config" -D CMAKE_BUILD_TYPE:STRING=RelWithDebInfo -D FEATURE_TESTS:BOOL=ON
	cmake --build ./build --config RelWithDebInfo

	(cd build/my_exe/test && ctest -C RelWithDebInfo --output-on-failure)
	(cd build/my_header_lib/test && ctest -C RelWithDebInfo --output-on-failure)
	(cd build/my_lib/test && ctest -C RelWithDebInfo --output-on-failure)

docs:
	cmake ./ -B ./build -G "Ninja Multi-Config" -D CMAKE_BUILD_TYPE:STRING=Debug -D FEATURE_DOCS:BOOL=ON -D FEATURE_TESTS:BOOL=OFF
	cmake --build ./build --target doxygen-docs --config Debug

format:
	git ls-files --exclude-standard | grep -E '\.(cpp|hpp|c|cc|cxx|hxx|ixx)$$' | xargs clang-format -i -style=file
	git ls-files --exclude-standard | grep -E '(\.cmake|CMakeLists.txt)$$' | xargs cmake-format -i

clean:
	rm -rf ./build
