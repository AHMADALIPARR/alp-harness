cmake_minimum_required(VERSION 3.16)
project(hpc_termination VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_library(hpc_termination
    src/termination.cpp
    src/dependency_graph.cpp
    src/stratification.cpp
    src/domain.cpp
    src/certificate.cpp
)
target_include_directories(hpc_termination PUBLIC include)
target_compile_options(hpc_termination PRIVATE -Wall -Wextra -Wpedantic)

add_executable(hpc-termination examples/main.cpp)
target_link_libraries(hpc-termination PRIVATE hpc_termination)

enable_testing()
add_executable(hpc-termination-tests tests/test_termination.cpp)
target_link_libraries(hpc-termination-tests PRIVATE hpc_termination)
add_test(NAME hpc-termination-tests COMMAND hpc-termination-tests)
