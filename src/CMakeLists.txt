
if(${MPV_AVAILABLE})
    set(mpvSRCS
        backends/mpv/mpvobject.cpp
        backends/mpv/track.cpp
        backends/mpv/tracksmodel.cpp
        backends/mpv/subtitlesfoldersmodel.cpp
        backends/mpv/qthelper.h
        )
endif()

set(clipSRCS
    main.cpp
    models/videosmodel.cpp
    models/tagsmodel.cpp
    models/playlistmodel.cpp
    models/youtubemodel.cpp
    utils/clip.cpp
    controllers/youtube.cpp
    )

set(clipHDRS
    models/videosmodel.h
    models/tagsmodel.h
    models/playlistmodel.h
    models/youtubemodel.h
    utils/clip.h
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
        ${mpvSRCS}
        )
else()
    add_executable(${PROJECT_NAME}
        ${clipSRCS}
        ${clipHDRS}
        ${clipASSETS}
        ${mpvSRCS}
        )
endif()

if (ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} Qt5::Widgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_compile_options(${PROJECT_NAME} PRIVATE -fexceptions)

if(${MPV_AVAILABLE})
    target_link_libraries(${PROJECT_NAME} mpv)
    add_definitions(-DMPV_AVAILABLE)
    target_compile_definitions(${PROJECT_NAME} PUBLIC MPV_AVAILABLE)
endif()

target_link_libraries(${PROJECT_NAME} MauiKit MauiKit::FileBrowsing Qt5::Quick Qt5::Qml Qt5::Multimedia KF5::CoreAddons KF5::I18n)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install (TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.kde.clip.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
    #TODO: port to ecm_install_icons()
    install(FILES assets/clip.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()
