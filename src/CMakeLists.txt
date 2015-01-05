
set (CONFIG_FILE ${CMAKE_CURRENT_BINARY_DIR}/config.vala)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/config.vala.cmake ${CONFIG_FILE})

vala_precompile (VALA_C ${CMAKE_PROJECT_NAME}
    ${CONFIG_FILE}
    Window.vala
    GeoClue.vala
    View/SearchOptionSelector.vala
PACKAGES
    gtk+-3.0
    granite
    champlain-gtk-0.12
    champlain-0.12
    clutter-1.0
    geocode-glib-1.0
OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --target-glib=2.32
    --thread
)

add_executable (${CMAKE_PROJECT_NAME} ${VALA_C})
target_link_libraries (${CMAKE_PROJECT_NAME} ${DEPS_LIBRARIES})

# Installation
install (TARGETS ${CMAKE_PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})
