#[[
    Abstractions and Models are NOT at WAR!
                                            - Cobwoy's Talisman
    But Abstractions don't care and Models can't understand!!
                                            - Lul, Practicality
 ]]

# Set the project name and version
project(spdlogging VERSION 1.0) # Versioning shall change to something more appropriate

set(SPDLOG_SRCS src/dummy.cpp)
file(GLOB_RECURSE HEADERFILES ${CMAKE_CURRENT_SOURCE_DIR}/include/spdlog/*.h)

# Some preprocessor definitions
add_compile_definitions(SPDLOG_COMPILED_LIB)
add_compile_definitions(FMT_USE_NONTYPE_TEMPLATE_PARAMETERS=0)

# Since Windows has exception with regards to Static/Dynamic libraries, we just compile a dummy
#if (BUILD_SHARED_LIBS)
    add_library(spdlogging SHARED ${SPDLOG_SRCS} ${HEADERFILES})
#else()
#    add_library(spdlogging STATIC ${SPDLOG_SRCS} ${HEADERFILES})
#endif()

target_include_directories(spdlogging
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(spdlogging PROPERTIES FOLDER "${KARMALIBRARYFOLDER}")

target_compile_definitions(spdlogging PUBLIC spdlogging)

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
