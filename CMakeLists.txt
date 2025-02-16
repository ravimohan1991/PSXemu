#[[
    Abstractions and Models are NOT at WAR!
                                            - Cobwoy's Talisman
    But Abstractions don't care and Models can't understand!!
                                            - Lul, Practicality
 ]]
cmake_minimum_required(VERSION 3.4)

# This is the top level CMakeList file having single responsibility of
# generating enough context for entire Software (Engine + Application).

# First we specify the C++/C standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_C_STANDARD 17)

# Control where the static and shared libraries are built
# We would want a semi-packaging fashioned way where all bianries are together
# whilst accessible from IDE (local debugger for instance!).
set(REPOSITORYROOT "${CMAKE_CURRENT_SOURCE_DIR}")
# Global variable for Karma's Libraries
set(KARMALIBRARYFOLDER "CompanionLibraries")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${REPOSITORYROOT}/KarmaBin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${REPOSITORYROOT}/KarmaBin")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${REPOSITORYROOT}/KarmaBin")

# Set the GameName
set(KARMA_GAME_NAME "PSXEmu")

# Finally we specify policies, if any
# This one is for inter-directory linking
cmake_policy(SET CMP0079 NEW)

# Setting some options
option(BUILD_SHARED_LIBS "Build shared libraries" ON)

# Setting some properties
# For grouping Libraries in folder
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
# Clustering ALL_BUILD and related crap projects (within the context of IDE)
# set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "Si")
# If want to disable ZERO_CHECK
# set(CMAKE_SUPPRESS_REGENERATION true)

#----------------------------------------------------------------------------#

# Set Engine project
project(${KARMA_GAME_NAME} VERSION 1.0)

# Setting some flags

# For complete list of Compiler IDs check output_required_files
# https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_ID.html#variable:CMAKE_%3CLANG%3E_COMPILER_ID
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-deprecated-enum-enum-conversion")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Werror-implicit-function-declaration")
endif()

add_compile_definitions(IMGUI_IMPL_OPENGL_LOADER_GLAD)
add_compile_definitions(STBI_NO_STDIO)

# Platform specific defines
# NOTE: These defines transcend libraries
if(WIN32)
    add_compile_definitions(KR_WINDOWS_PLATFORM)
        if(MSVC)
            # For faster multithreaded compilation
        #add_definitions(/MP)
        add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
        endif()
elseif(UNIX AND NOT APPLE)
    add_compile_definitions(KR_LINUX_PLATFORM)
elseif(APPLE)
    add_compile_definitions(KR_MAC_PLATFORM)
endif()

# Then we specify the involved libraries
add_subdirectory(libraries/glm)
add_subdirectory(libraries/glad)
add_subdirectory(libraries/spdlog)
add_subdirectory(libraries/glfw)

# The emulator software directory
add_subdirectory(core)


target_link_libraries(core PUBLIC glm)
target_link_libraries(core PUBLIC glfw)

target_link_libraries(core PUBLIC spdlogging)

#[[
 *                                          /\
 *                                         / /
 *                                      /\| |
 *                                      | | |/\
 *                                      | | / /
 *                                      | `  /
 *                                      `\  (___
 *                                     _.->  ,-.-.
 *                                  _.'      |  \ \
 *                                 /    _____| 0 |0\
 *                                |    /`    `^-.\.-'`-._
 *                                |   |                  `-._
 *                                |   :                      `.
 *                                \    `._     `-.__         O.'
 *         _.--,                   \     `._     __.^--._O_..-'
 *        `---, `.                  `\     /` ` `
 *             `\ `,                  `\   |
 *              |   :                   ;  |
 *              /    `.              ___|__|___
 *             /       `.           (          )
 *            /    `---.:____...---' `--------`.
 *           /        (         `.      __      `.
 *          |          `---------' _   /  \       \
 *          |    .-.      _._     (_)  `--'        \
 *          |   (   )    /   \                       \
 *           \   `-'     \   /                       ;-._
 *            \           `-'           \           .'   `.
 *            /`.                  `\    `\     _.-'`-.    `.___
 *           |   `-._                `\    `\.-'       `-.   ,--`
 *            \      `--.___        ___`\    \           ||^\\
 *             `._        | ``----''     `.   `\         `'  `
 *                `--;     \  jgs          `.   `.
 *                   //^||^\\               //^||^\\
 *                   '  `'  `               '   '  `
 ]]
