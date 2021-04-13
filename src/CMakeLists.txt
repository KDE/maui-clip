
set(clipSRCS
    main.cpp
    models/videosmodel.cpp
    models/tagsmodel.cpp
    models/playlistmodel.cpp
    models/youtubemodel.cpp
    utils/clip.cpp
    backends/mpv/mpvobject.cpp
    backends/mpv/track.cpp
    backends/mpv/tracksmodel.cpp
    backends/mpv/subtitlesfoldersmodel.cpp
    controllers/youtube.cpp
    )

set(clipHDRS
    models/videosmodel.h
    models/tagsmodel.h
    models/playlistmodel.h
    models/youtubemodel.h
    utils/clip.h
    backends/mpv/mpvobject.h
    backends/mpv/track.h
    backends/mpv/tracksmodel.h
    backends/mpv/subtitlesfoldersmodel.h
    backends/mpv/qthelper.h
    controllers/youtube.h
    )

set(clipASSETS
    qml.qrc
    )

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${clipSRCS}
        ${clipHDRS}
        ${clipASSETS}
        )
else()
    add_executable(${PROJECT_NAME}
        ${clipSRCS}
        ${clipHDRS}
        ${clipASSETS}
        )
endif()


if (ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} KF5::ConfigCore KF5::KIOCore KF5::KIOFileWidgets KF5::KIONTLM KF5::KIOWidgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_compile_options(${PROJECT_NAME} PRIVATE -fexceptions)

target_link_libraries(${PROJECT_NAME} MauiKit MauiKit::FileBrowsing Qt5::Sql Qt5::Quick Qt5::Qml Qt5::Svg Qt5::Multimedia KF5::CoreAddons KF5::I18n mpv)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install (TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.maui.clip.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
    #TODO: port to ecm_install_icons()
    install(FILES assets/clip.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()
