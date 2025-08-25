#[[
    Abstractions and Models are NOT at WAR!
                                            - Cobwoy's Talisman
    But Abstractions don't care and Models can't understand!!
                                            - Lul, Practicality
 ]]

# Macros
# Recursive directory list generator
# Snippet gracefully taken from https://stackoverflow.com/a/53017508
MACRO(COLLECTIVEINCLUDES CurrentDir)
    FILE(GLOB_RECURSE Children LIST_DIRECTORIES true RELATIVE ${CurrentDir} ${CurrentDir}/*)
    FOREACH(Child ${Children})
        IF(IS_DIRECTORY ${CurrentDir}/${Child})
        target_include_directories(KarmaEngine
            PRIVATE
            ${CurrentDir}/${Child}
            PUBLIC
            $<BUILD_INTERFACE:${CurrentDir}/${Child}>
        )
        ENDIF()
    ENDFOREACH()
ENDMACRO()

# Introducing the same directory hierarchy in the solution projects (for MSVC and Xcode)
# Snippet gracefully taken from https://blog.audio-tk.com/2015/09/01/sorting-source-files-and-projects-in-folders-with-cmake-and-visual-studioxcode/
MACRO(SOURCE_GROUP_BY_FOLDER Target)
    SET(SOURCE_GROUP_DELIMITER "/")
    SET(Last_Dir "")
    SET(Files "")
    message(STATUS "Organizing KarmaEngine's files by same, project directory hierarchy.")
    FOREACH(File ${CPPFILES} ${HEADERFILES} ${CFILES} ${HEADERCFILES})
        FILE(RELATIVE_PATH Relative_File "${PROJECT_SOURCE_DIR}/${Target}" ${File})
        GET_FILENAME_COMPONENT(Dir "${Relative_File}" PATH)
        IF (NOT "${Dir}" STREQUAL "${Last_Dir}")
            IF (Files)
                SOURCE_GROUP("${Last_Dir}" FILES ${Files})
            ENDIF (Files)
            SET(Files "")
        ENDIF (NOT "${Dir}" STREQUAL "${Last_Dir}")
        SET(Files ${Files} ${File})
        SET(Last_Dir "${Dir}")
    ENDFOREACH(File)
    IF (Files)
        SOURCE_GROUP("${Last_Dir}" FILES ${Files})
    ENDIF (Files)
ENDMACRO(SOURCE_GROUP_BY_FOLDER)

# Print a list with style
MACRO(PRINT_LIST PList)
	SET(Counter 0)
	FOREACH(Elem IN LISTS ${PList})
		MATH(EXPR Counter "${Counter}+1")
		message(STATUS "#${Counter}: ${Elem}")
	ENDFOREACH(Elem)
ENDMACRO(PRINT_LIST)

# Then the checks
find_package(Vulkan REQUIRED)
find_package(OpenGL REQUIRED)
find_package(Threads REQUIRED)
message(STATUS "Checks are satisfied, we are good to proceed!")

# Vulkan detection specific code
# also see https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/How-To-Write-Platform-Checks#platform-variables
if(WIN32)
  set(_Vulkan_library_name vulkan-1)
  set(_Vulkan_hint_include_search_paths
    "$ENV{VULKAN_SDK}/Include"
  )
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(_Vulkan_hint_executable_search_paths
      "$ENV{VULKAN_SDK}/Bin"
    )
    set(_Vulkan_hint_library_search_paths
      "$ENV{VULKAN_SDK}/Lib"
      "$ENV{VULKAN_SDK}/Bin"
    )
  else()
    set(_Vulkan_hint_executable_search_paths
      "$ENV{VULKAN_SDK}/Bin32"
    )
    set(_Vulkan_hint_library_search_paths
      "$ENV{VULKAN_SDK}/Lib32"
      "$ENV{VULKAN_SDK}/Bin32"
    )
  endif()
else()
  set(_Vulkan_library_name vulkan)
  set(_Vulkan_hint_include_search_paths
    "$ENV{VULKAN_SDK}/include"
  )
  set(_Vulkan_hint_executable_search_paths
    "$ENV{VULKAN_SDK}/bin"
  )
  set(_Vulkan_hint_library_search_paths
    "$ENV{VULKAN_SDK}/lib"
  )
endif()
if(APPLE AND DEFINED ENV{VULKAN_SDK})
  cmake_path(SET _MoltenVK_path NORMALIZE "$ENV{VULKAN_SDK}/../MoltenVK")
  if(EXISTS "${_MoltenVK_path}")
    list(APPEND _Vulkan_hint_include_search_paths
      "${_MoltenVK_path}/include"
    )
    if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
      list(APPEND _Vulkan_hint_library_search_paths
        "${_MoltenVK_path}/dylib/iOS"
      )
    elseif(CMAKE_SYSTEM_NAME STREQUAL "tvOS")
      list(APPEND _Vulkan_hint_library_search_paths
        "${_MoltenVK_path}/dylib/tvOS"
      )
    else()
      list(APPEND _Vulkan_hint_library_search_paths
        "${_MoltenVK_path}/dylib/macOS"
      )
    endif()
  endif()
  unset(_MoltenVK_path)
endif()
if(UNIX AND NOT APPLE)
    # May need to set up in Windows and Mac
    message(STATUS "YEEHAW FOUND LINUX only")
    find_path(Vulkan_INCLUDE_DIR
      NAMES vulkan/vulkan.h
      HINTS
        ${_Vulkan_hint_include_search_paths}
      )
    mark_as_advanced(Vulkan_INCLUDE_DIR)

    find_library(Vulkan_LIBRARY
      NAMES ${_Vulkan_library_name}
      HINTS
        ${_Vulkan_hint_library_search_paths}
      )
    mark_as_advanced(Vulkan_LIBRARY)
endif()

# If using MSVC (Windows), we need dynamic libraries' members exported
if(MSVC AND WIN32)
    if(BUILD_SHARED_LIBS)
        set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    endif()
endif()

# Some defines
# add_compile_definitions(IMGUI_IMPL_VULKAN_NO_PROTOTYPES)

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

# Configuration specific defines/settings
if(NOT CMAKE_BUILD_TYPE STREQUAL "Release")
	add_compile_definitions(KR_ENABLE_ASSERTS)
endif()
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
	add_compile_definitions(KR_DEBUG)
endif()

# Metal
find_library(METAL Metal)
find_library(FOUNDATION Foundation)
find_library(QUARTZCORE QuartzCore)
find_library(APPKIT AppKit)

# Set the project name and version
project(Emulator VERSION 1.0) # Versioning shall change to something more appropriate

# Karma's personal code
file(GLOB_RECURSE CPPFILES ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
file(GLOB_RECURSE CFILES ${CMAKE_CURRENT_SOURCE_DIR}/*.c)
# Shows the headerfile directory in project
file(GLOB_RECURSE HEADERFILES ${CMAKE_CURRENT_SOURCE_DIR}/*.h)
file(GLOB_RECURSE HEADERCFILES ${CMAKE_CURRENT_SOURCE_DIR}/*.hpp)

SOURCE_GROUP_BY_FOLDER(../Emulator)

# Building the project (STATIC or DYNAMIC (SHARED))
add_executable(Emulator ${CPPFILES} ${CFILES} ${HEADERFILES} ${HEADERCFILES})


target_include_directories(Emulator
    PRIVATE
        # where the library itself will look for its internal headers
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/../libraries/glad/include
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui
)

# INTERFACE (Something that Consumers require but Producers don't)
# Since I am a library coder here, I am the Producer
# Rest of the Engine is Consumer here

target_compile_definitions(Emulator PUBLIC Emulator)

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
