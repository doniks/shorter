

set(
    shorts_src
    main.cpp
    networkmanager.cpp
    CachingNetworkManagerFactory.cpp
    shorts.qrc
    xml2json/utilities.cpp

    )

add_executable(${EXEC}
    ${shorts_src}
    )

qt5_use_modules(${EXEC} Core Qml Quick Gui Network)

#install(TARGETS ${EXEC} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(TARGETS ${EXEC} RUNTIME DESTINATION ${BIN_DIR})


add_subdirectory(qml)
add_subdirectory(po)
# add_subdirectory(shorts)
# add_subdirectory(shorts)
# add_subdirectory(shorts)
# add_subdirectory(shorts)
