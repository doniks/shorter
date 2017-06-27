file(GLOB ICONS *.svg)

# make the files visible in the qtcreator tree
add_custom_target(icons_QMlFiles ALL SOURCES ${ICONS})

install(FILES ${ICONS} DESTINATION ${SHORTS_DIR}/icons/)
