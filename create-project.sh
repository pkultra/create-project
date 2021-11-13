#!/usr/bin/bash
set -oeu pipefail

Help()
{
   # Display Help
   echo "This creates a C++/CUDA CMake project with <project_name> inside <project_path>, with a simple project structure and CMakeLists.txt files."
   echo
   echo "Syntax: create-project [-h|c] <project_path>/<project_name>"
   echo "options:"
   echo "-h     Print this Help."
   echo "-c     Create CUDA-enabled project."
   echo
}

dir=$1
CUDA_LANGUAGE_FLAG=
CUDA_INCL_PATH=
CUDA_SRC=
# Get the options
while getopts ":hc" option; do
   case $option in
      h) # display Help
         Help
         exit;;
	  c) 
		 CUDA_LANGUAGE_FLAG=" LANGUAGES CXX CUDA"
		 CUDA_INCL_PATH="include_directories(\${CMAKE_CUDA_TOOLKIT_INCLUDE_DIRECTORIES})"
		 CUDA_SRC=" \${SRCPATH}/*.cu"
		 dir=$2;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done
#echo ${CUDA_LANGUAGE_FLAG}
#exit

project_name=$(basename "${dir}")

mkdir -p "${dir}"
mkdir -p "${dir}/include"
mkdir -p "${dir}/src"
mkdir -p "${dir}/test"

# add test folder CMakeLists file
cat << EOF > "${dir}/test/CMakeLists.txt"
cmake_minimum_required(VERSION 3.8)
project(runTests${CUDA_LANGUAGE_FLAG})

set (CMAKE_CXX_STANDARD 20)

# Locate GTest
find_package(GTest REQUIRED)

# Set source files and headers
${CUDA_INCL_PATH}
set(SRCPATH ../src)
set(INCLPATH ../include)
include_directories(\${GTEST_INCLUDE_DIRS} \${INCLPATH})
file(GLOB SOURCES \${SRCPATH}/*.cpp${CUDA_SRC})
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
cmake_minimum_required(VERSION 3.8)
project(${project_name}${CUDA_LANGUAGE_FLAG})
set (CMAKE_CXX_STANDARD 20)

# Set source files and headers
${CUDA_INCL_PATH}
set(SRCPATH ./src)
set(INCLPATH ./include)
include_directories(\${INCLPATH})
file(GLOB SOURCES \${SRCPATH}/*.cpp${CUDA_SRC})

add_executable(${project_name} main.cpp \${SOURCES})
target_link_libraries(${project_name})
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
