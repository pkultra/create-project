#!/usr/bin/bash
set -oeu pipefail

if [ "$#" -eq 0 ] || [ "$1" == "-h" ]; then
  echo "Usage: create_project <project_path/project_name>."
  echo "This creates a C++ CMake project with <project_name> inside <project_path>, with a simple project structure and CMakeLists.txt files."
  exit 0
fi

dir=$1
project_name=$(basename "${dir}")

mkdir -p "${dir}"
mkdir -p "${dir}/src"
mkdir -p "${dir}/test"

# add test folder CMakeLists file
cat << EOF > "${dir}/test/CMakeLists.txt"
cmake_minimum_required(VERSION 2.6)

set (CMAKE_CXX_STANDARD 20)

# Locate GTest
find_package(GTest REQUIRED)

# Set source files and headers
set(SRCPATH ../src)
include_directories(\${GTEST_INCLUDE_DIRS} \${SRCPATH})
file(GLOB SOURCES \${SRCPATH}/*.cpp)
file(GLOB TESTSRCS ./*.cpp)

# Link runTests with what we want to test and the GTest and pthread library
add_executable(runTests \${TESTSRCS} \${SOURCES})
target_link_libraries(runTests \${GTEST_LIBRARIES} pthread)
EOF

# add runTests.cpp
cat << EOF > "${dir}/test/runTests.cpp"
#include <gtest/gtest.h>
int main(int argc, char **argv) {
	testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}
EOF

# add project CMakeLists file
cat <<EOF > "${dir}/CMakeLists.txt"
cmake_minimum_required(VERSION 2.6)
project(${project_name})
set (CMAKE_CXX_STANDARD 20)

# Set source files and headers
set(SRCPATH ./src)
include_directories(\${GTEST_INCLUDE_DIRS} \${SRCPATH})
file(GLOB SOURCES \${SRCPATH}/*.cpp)

add_executable(${project_name} main.cpp \${SOURCES})
target_link_libraries(${project_name} \${GTEST_LIBRARIES} pthread)
EOF

# add main.cpp file
cat <<EOF > "${dir}/main.cpp"
#include <iostream>
int main()
{
	std::cout<<"hello world\n";
	return 0;
}
EOF
