#!/bin/bash
has_submodule=false
project_name="HelloWorld"

while [[ $# -gt 0 ]]; do
    case $1 in
        --submodule|-s)
            has_submodule=true
            shift
            ;;
        --project-name|-n)
            project_name="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "Creating project with name: $project_name"

if [ $has_submodule = true ];
then
    echo "Using submodule"
    git submodule add https://github.com/microsoft/vcpkg.git

    git submodule update --init --recursive

    if [ -e ".gitignore" ];
    then
        echo "Updating .gitignore"
    else
        echo "Creating .gitignore"
        touch .gitignore
    fi

    if ! grep -q "vcpkg/" .gitignore; then
        echo "vcpkg/" >> .gitignore
    fi

    if ! grep -q "vcpkg_installed/" .gitignore; then
        echo "vcpkg_installed/" >> .gitignore
    fi

    if ! grep -q "build/" .gitignore; then
        echo "build/" >> .gitignore
    fi
    
else
    echo "Cloning locally"
    git clone https://github.com/microsoft/vcpkg.git
fi

echo "Creating directories"
mkdir -p include
mkdir -p src
mkdir -p lib

echo Running vcpkg bootstrap
./vcpkg/bootstrap-vcpkg.sh

echo Creating vcpkg project
./vcpkg/vcpkg new --application

echo Setting up CMake

touch CMakeLists.txt

echo "
cmake_minimum_required(VERSION 3.10)

project($project_name)

# Include paths
target_include_directories($project_name PRIVATE include)

# Source paths
file(GLOB SOURCES src/*.cpp)
add_executable(HelloWorld \${SOURCES})

# Link libraries

" > CMakeLists.txt

touch CMakePresets.json
echo "
{
    \"version\": 2,
    \"configurePresets\": [
        {
            \"name\": \"default\",
            \"generator\": \"Unix Makefiles\",
            \"binaryDir\": \"\${sourceDir}/build\",
            \"cacheVariables\": {
                \"CMAKE_TOOLCHAIN_FILE\": \"\${sourceDir}/vcpkg/scripts/buildsystems/vcpkg.cmake\"
            }
        }
    ]
}
" > CMakePresets.json








