
include_directories(
    ${FFMPEG_INCLUDE_DIRS}
    )

if(MPV_AVAILABLE)
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

set(thumbnailerSRCS
    utils/thumbnailer.cpp
    utils/ffmpegthumbs/filmstripfilter.cpp
    utils/ffmpegthumbs/moviedecoder.cpp
    utils/ffmpegthumbs/imagewriter.cpp
    utils/ffmpegthumbs/videothumbnailer.cpp
    )

if(QUICK_COMPILER)
    qtquick_compiler_add_resources(clip_QML_QRC qml.qrc)
else()
    qt5_add_resources(clip_QML_QRC qml.qrc)
endif()

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${clipSRCS}
        ${thumbnailerSRCS}
        ${clip_QML_QRC}
        )
else()
    add_executable(${PROJECT_NAME}
        ${clipSRCS}
        ${thumbnailerSRCS}
        ${clip_QML_QRC}
        ${mpvSRCS}
        )
endif()

if (ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2)
else()
    target_link_libraries(${PROJECT_NAME} Qt5::Widgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_compile_options(${PROJECT_NAME} PRIVATE -fexceptions)

if(MPV_AVAILABLE)
    target_link_libraries(${PROJECT_NAME} mpv)
    add_definitions(-DMPV_AVAILABLE)
    target_compile_definitions(${PROJECT_NAME} PUBLIC MPV_AVAILABLE)
endif()

target_link_libraries(${PROJECT_NAME} MauiKit MauiKit::FileBrowsing Qt5::Quick Qt5::Qml Qt5::Multimedia KF5::CoreAddons KF5::I18n  ${AVUTIL_LIBRARIES} ${AVFILTER_LIBRARIES} ${AVFORMAT_LIBRARIES} ${AVCODEC_LIBRARIES} ${SWSCALE_LIBRARIES} Taglib::Taglib)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install (TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.kde.clip.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
    #TODO: port to ecm_install_icons()
    install(FILES assets/clip.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()
