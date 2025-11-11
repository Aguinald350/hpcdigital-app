# ===============================
# 🔧 Project-level configuration
# ===============================
cmake_minimum_required(VERSION 3.14)
project(hpcdigital LANGUAGES CXX)

set(BINARY_NAME "hpcdigital")

cmake_policy(VERSION 3.14...3.25)

# ===============================
# 🧩 Build configuration
# ===============================
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
    set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release" CACHE STRING "" FORCE)
else()
    if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
        set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
        set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Profile" "Release")
    endif()
endif()

# 🔧 Definições para o modo Profile (exigidas pelo toolchain do Flutter)
set(CMAKE_EXE_LINKER_FLAGS_PROFILE     "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE  "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE              "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE            "${CMAKE_CXX_FLAGS_RELEASE}")

# ===============================
# ⚙️ Compiler settings
# ===============================
add_definitions(-DUNICODE -D_UNICODE)

# ✅ Patch global: silenciar C4996 e não tratar warnings como erro no MSVC
if(MSVC)
    message(STATUS "Applying MSVC global options (/wd4996 /WX-)")
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
    add_compile_options(/wd4996 /WX-)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /wd4996 /WX-")
    set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   /wd4996 /WX-")
endif()

# ===============================
# 📦 Custom HPC settings
# ===============================
function(apply_hpc_settings TARGET)
    target_compile_features(${TARGET} PUBLIC cxx_std_17)
    if(MSVC)
        target_compile_options(${TARGET} PRIVATE /W4 /EHsc /wd4996 /WX-)
        target_compile_definitions(${TARGET} PRIVATE _CRT_SECURE_NO_WARNINGS)
    else()
        target_compile_options(${TARGET} PRIVATE -Wall -Wextra)
    endif()
    target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
    target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# ✅ Proxy que o Flutter espera (evita "Unknown CMake command apply_standard_settings")
function(apply_standard_settings TARGET)
    apply_hpc_settings(${TARGET})
endfunction()

# ===============================
# 🪶 Flutter build rules
# ===============================
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# ===============================
# 🏃 Application runner
# ===============================
add_subdirectory("runner")

# ===============================
# 🔌 Plugins
# ===============================
include(flutter/generated_plugins.cmake)

# ===============================
# 📦 Installation rules
# ===============================
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR  "${CMAKE_INSTALL_PREFIX}")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)

install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)
install(FILES "${FLUTTER_LIBRARY}"       DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"  COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
    install(FILES "${PLUGIN_BUNDLED_LIBRARIES}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}" COMPONENT Runtime)
endif()

set(NATIVE_ASSETS_DIR "${PROJECT_BUILD_DIR}native_assets/windows/")
install(DIRECTORY "${NATIVE_ASSETS_DIR}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}" COMPONENT Runtime)

set(FLUTTER_ASSET_DIR_NAME "flutter_assets")
install(CODE "file(REMOVE_RECURSE \"${INSTALL_BUNDLE_DATA_DIR}/${FLUTTER_ASSET_DIR_NAME}\")" COMPONENT Runtime)
install(DIRECTORY "${PROJECT_BUILD_DIR}/${FLUTTER_ASSET_DIR_NAME}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" COMPONENT Runtime)

install(FILES "${AOT_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}" CONFIGURATIONS Profile;Release COMPONENT Runtime)
