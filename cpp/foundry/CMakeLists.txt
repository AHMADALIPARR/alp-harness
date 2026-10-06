cmake_minimum_required(VERSION 3.20)
project(foundry_gate VERSION 1.0.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_library(foundry_core STATIC
    src/goldilocks.cpp src/pmat.cpp src/spectral.cpp src/recurrence.cpp
    src/gate.cpp src/certify.cpp src/audit.cpp src/sha256.cpp)
target_include_directories(foundry_core PUBLIC include)
# src/main.cpp calls TripleLock with fewer arguments than gate.h. It is not a build target.
add_executable(foundry_test src/test.cpp)
target_link_libraries(foundry_test PRIVATE foundry_core)
add_executable(harness_join src/harness_join.cpp
    ../hpc-termination/src/termination.cpp
    ../hpc-termination/src/dependency_graph.cpp
    ../hpc-termination/src/stratification.cpp
    ../hpc-termination/src/domain.cpp
    ../hpc-termination/src/certificate.cpp)
target_include_directories(harness_join PRIVATE ../hpc-termination/include)
target_link_libraries(harness_join PRIVATE foundry_core)
enable_testing()
add_test(NAME foundry_test COMMAND foundry_test)
add_test(NAME harness_join COMMAND harness_join)
