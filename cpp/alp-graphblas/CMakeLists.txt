cmake_minimum_required(VERSION 3.20)
project(alp_graphblas VERSION 0.2.0 LANGUAGES CXX)

option(ALP_GRAPHBLAS_ENABLE "Build the ALP/GraphBLAS backend" ON)
option(ALP_BUILD_TESTS "Build the test suite" ON)
set(ALP_ROOT "" CACHE PATH "Root of an ALP/GraphBLAS *installation* (contains include/graphblas.hpp and lib/)")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "" FORCE)
endif()

set(ALP_WARNINGS -Wall -Wextra -Wpedantic)

# --- logic layer: parser, unification, stratified inference, integrity, abduction ---
add_library(alp_logic
    src/term.cpp src/atom.cpp src/clause.cpp src/unification.cpp src/knowledge_base.cpp
    src/fact_store.cpp src/matching.cpp src/stratification.cpp src/inference.cpp
    src/integrity.cpp src/abduction.cpp src/model.cpp src/parser.cpp
    src/term_ops.cpp src/provenance.cpp
    src/logic/sld.cpp src/logic/runtime.cpp
    src/analysis/dependency.cpp src/analysis/validation.cpp
    src/io/serialization.cpp src/io/lexer.cpp
    src/constraints/constraint.cpp
)
target_include_directories(alp_logic PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_compile_features(alp_logic PUBLIC cxx_std_20)
target_compile_options(alp_logic PRIVATE ${ALP_WARNINGS})

# --- graph layer: always built; uses ALP/GraphBLAS when enabled, else the reference closure ---
add_library(alp_graph
    src/graph/graph_index.cpp src/graph/graph.cpp src/graph/adjacency.cpp src/graph/fixed_point.cpp
    src/graph/reachability.cpp src/graph/predicates.cpp src/graph/bridge.cpp
    src/graph/operations.cpp src/graph/export.cpp
)
target_link_libraries(alp_graph PUBLIC alp_logic)
target_compile_options(alp_graph PRIVATE ${ALP_WARNINGS})

if(ALP_GRAPHBLAS_ENABLE)
    if(NOT ALP_ROOT)
        message(FATAL_ERROR "ALP_GRAPHBLAS_ENABLE=ON requires -DALP_ROOT=/path/to/ALP/install "
                            "(or configure with -DALP_GRAPHBLAS_ENABLE=OFF)")
    endif()
    find_path(ALP_GRAPHBLAS_INCLUDE_DIR graphblas.hpp HINTS "${ALP_ROOT}/include" REQUIRED NO_DEFAULT_PATH)
    find_library(ALP_UTILS_LIBRARY alp_utils HINTS "${ALP_ROOT}/lib" REQUIRED NO_DEFAULT_PATH)
    find_library(ALP_BACKEND_LIBRARY graphblas HINTS "${ALP_ROOT}/lib/sequential" REQUIRED NO_DEFAULT_PATH)
    find_package(OpenMP REQUIRED COMPONENTS CXX)
    find_library(NUMA_LIBRARY numa REQUIRED)

    target_sources(alp_graph PRIVATE src/graph/graphblas_backend.cpp)
    target_include_directories(alp_graph PRIVATE ${ALP_GRAPHBLAS_INCLUDE_DIR})
    # same definitions ALP's own `grbcxx -b reference` passes
    target_compile_definitions(alp_graph PUBLIC
        ALP_GRAPHBLAS_ENABLED=1 _GRB_WITH_REFERENCE _GRB_WITH_OMP _GRB_BACKEND=reference)
    target_link_libraries(alp_graph PUBLIC
        ${ALP_UTILS_LIBRARY} ${ALP_BACKEND_LIBRARY} OpenMP::OpenMP_CXX ${NUMA_LIBRARY})
endif()

# --- command line tool ---
add_executable(alp src/main.cpp)
target_link_libraries(alp PRIVATE alp_graph)
target_compile_options(alp PRIVATE ${ALP_WARNINGS})

# --- tests ---
if(ALP_BUILD_TESTS)
    include(CTest)
    enable_testing()
    function(alp_add_test name source)
        add_executable(${name} ${source})
        target_link_libraries(${name} PRIVATE alp_graph)
        target_include_directories(${name} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/tests)
        # tests rely on CHECK (always on), but keep assert() live too in Release builds
        target_compile_options(${name} PRIVATE ${ALP_WARNINGS} -UNDEBUG)
        add_test(NAME ${name} COMMAND ${name} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    endfunction()

    alp_add_test(test_unification tests/unification/unification_test.cpp)
    alp_add_test(test_parser      tests/unification/parser_test.cpp)
    alp_add_test(test_horn        tests/horn/horn_test.cpp)
    alp_add_test(test_integrity   tests/integrity/integrity_test.cpp)
    alp_add_test(test_abduction   tests/abduction/abduction_test.cpp)
    alp_add_test(test_graph       tests/graphblas/graph_test.cpp)
    alp_add_test(test_integration tests/integration/integration_test.cpp)
    alp_add_test(test_snap_core   tests/upstream/snap_core_test.cpp)
    alp_add_test(test_snap_graph  tests/upstream/snap_graph_test.cpp)
    if(ALP_GRAPHBLAS_ENABLE)
        alp_add_test(test_graphblas tests/graphblas/graphblas_test.cpp)
    endif()
endif()
