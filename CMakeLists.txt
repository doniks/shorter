project(doniks.shorter)
cmake_minimum_required(VERSION 2.8.9)
find_program(INTLTOOL_MERGE intltool-merge)
find_program(INTLTOOL_EXTRACT intltool-extract)

# Standard install paths
include(GNUInstallDirs)

option(INSTALL_TESTS "Install the tests on make install" on)
option(CLICK_MODE "Installs to a contained location" on)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -fno-permissive -pedantic -Wall -Wextra")

find_package(Qt5Core)
find_package(Qt5Gui)
find_package(Qt5Qml)
find_package(Qt5Quick)
find_package(Qt5Network)
# Find_package(ubuntu-sdk-libs)

#automatically create moc files
set(CMAKE_AUTOMOC ON)

#automatically add qrc files
set(CMAKE_AUTORCC ON)

# Figure out the component install path
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

#set(CLICK_ARCH "all")
# If you want to add native code to your project, replace the set CLICK_ARCH command
# with the following part.
# This command figures out the target architecture for use in the manifest file
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_ARCH
    OUTPUT_VARIABLE CLICK_ARCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QT_IMPORTS_DIR "lib/${ARCH_TRIPLET}")
set(BIN_DIR /lib/${ARCH_TRIPLET}/bin)


set(APP_NAME shorter)
set(DESKTOP_FILE "${APP_NAME}.desktop")
set(MAIN_QML shorts-app.qml)
set(ICON_FILE shorts.png)
set(SHORTS_DIR "share/qml")
set(AUTOPILOT_DIR shorts_app)
set(UBUNTU_MANIFEST_PATH "manifest.json.in" CACHE INTERNAL "Relative path to the manifest file")

if(CLICK_MODE)
    message("CLICK_MODE")
    # we go in here when building with clickable

    #if(NOT DEFINED BZR_SOURCE)
    #    set(BZR_SOURCE "lp:ubuntu-rssreader-app")
    #    message("-- Setting BZR_SOURCE to ${BZR_SOURCE}")
    #endif(NOT DEFINED BZR_SOURCE)
    set(CMAKE_INSTALL_PREFIX /)
    set(CMAKE_INSTALL_BINDIR /)
    set(DATA_DIR /)
    set(ICON ${ICON_FILE})
#     set(EXEC "qmlscene ${MAIN_QML}")
    set(EXEC ${APP_NAME})
    set(DESKTOP_DIR ${DATA_DIR})
    configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json ${APP_NAME}.apparmor
            DESTINATION ${CMAKE_INSTALL_PREFIX})
    file(GLOB CLICK_FILES
         RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
         *.json *.json.in *.apparmor)
    add_custom_target(click_files ALL SOURCES ${CLICK_FILES})
else(CLICK_MODE)
    message("NOT CLICK_MODE")
    set(DATA_DIR ${CMAKE_INSTALL_DATADIR}/${APP_NAME})
    set(EXEC ${APP_NAME})
    set(ICON ${CMAKE_INSTALL_PREFIX}/${DATA_DIR}/${ICON_FILE})
    configure_file(${APP_NAME}.in
        ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME})
    install(PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}
        DESTINATION ${CMAKE_INSTALL_BINDIR})
    set(DESKTOP_DIR ${CMAKE_INSTALL_DATADIR}/applications)
endif(CLICK_MODE)

file(GLOB_RECURSE I18N_SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/shorts/po
     *.js *.qml)
list(APPEND I18N_SRC_FILES ${DESKTOP_FILE}.in.in.h)
list(SORT I18N_SRC_FILES)



# for icon
file(GLOB DESKTOP_ICON *.png)
add_custom_target(icons ALL SOURCES ${DESKTOP_ICON})
install(FILES ${DESKTOP_ICON} DESTINATION ${DESKTOP_DIR})

configure_file(${DESKTOP_FILE}.in.in ${DESKTOP_FILE}.in)
add_custom_target(${DESKTOP_FILE} ALL
 COMMENT "Merging translations into ${DESKTOP_FILE}..."
 COMMAND LC_ALL=C ${INTLTOOL_MERGE} -d -u ${CMAKE_SOURCE_DIR}/shorts/po ${DESKTOP_FILE}.in ${DESKTOP_FILE}
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${DESKTOP_FILE}
 DESTINATION ${DESKTOP_DIR})

# Tests
# enable_testing()

# add_subdirectory(click)
# add_subdirectory(po)
# add_subdirectory(tests)
# add_subdirectory(feeds)
add_subdirectory(shorts)
