remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_URL_CAST_FROM_STRING)

include_directories(
    ${FFMPEG_INCLUDE_DIRS})

if(MPV_AVAILABLE)
    set(mpvSRCS
        backends/mpv/mpvobject.cpp
        backends/mpv/track.cpp
        backends/mpv/tracksmodel.cpp
        backends/mpv/subtitlesfoldersmodel.cpp
        backends/mpv/qthelper.h)
endif()

set(clipSRCS
    main.cpp
    models/videosmodel.cpp
    models/tagsmodel.cpp
    models/playlistmodel.cpp
    # models/youtubemodel.cpp
    utils/clip.cpp
    controllers/lockmanager.cpp)

set(clip_ASSETS
    assets.qrc)

set(thumbnailerSRCS
    utils/thumbnailer.cpp
    utils/ffmpegthumbs/filmstripfilter.cpp
    utils/ffmpegthumbs/moviedecoder.cpp
    utils/ffmpegthumbs/imagewriter.cpp
    utils/ffmpegthumbs/videothumbnailer.cpp)

if(ANDROID)
    list(APPEND clipSRCS
        controllers/android/androidlockbackend.cpp)

    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
        ${clipSRCS}
        ${clip_ASSETS}
        ${thumbnailerSRCS})

    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android_files)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android_files/version.gradle.in ${CMAKE_BINARY_DIR}/src/version.gradle)

else()
    list(APPEND clipSRCS
        controllers/linux/solidlockbackend.cpp)
    qt_add_dbus_interface(clipSRCS controllers/linux/org.freedesktop.ScreenSaver.xml screensaverdbusinterface)

    qt_add_executable(${PROJECT_NAME}
        ${clipSRCS}
         ${clip_ASSETS}
        ${thumbnailerSRCS}
        ${mpvSRCS})
endif()


qt_add_qml_module(${PROJECT_NAME} URI app.maui.clip
    NO_PLUGIN
    QML_FILES
    main.qml
    views/player/PlayerView.qml
    views/player/MPVPlayer.qml
    views/collection/CollectionView.qml
    views/SelectionBar.qml
    views/tags/TagsView.qml
    views/player/Playlist.qml
    views/tags/TagsGrid.qml
    views/BrowserLayout.qml
    views/ItemMenu.qml
    views/ListDelegate.qml
    views/FloatingVideo.qml
    views/settings/SettingsDialog.qml
    views/youtube/YouTubeView.qml
    views/player/Player.qml
    views/collection/PlacesSidebar.qml)

if (ANDROID)
    find_package(OpenSSL REQUIRED)

    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Qt6::QuickControls2
        OpenSSL::SSL)

    message(${ANDROID_SDK_ROOT})

    # include(${ANDROID_SDK_ROOT}/openssl/android_openssl.cmake)
    # add_android_openssl_libraries(${PROJECT_NAME})

    # set_property(TARGET ${PROJECT_NAME} PROPERTY QT_ANDROID_EXTRA_LIBS
    #     ${ANDROID_SDK_ROOT}/openssl/ssl_3/arm64-v8a/libcrypto.so
    #     ${ANDROID_SDK_ROOT}/openssl/ssl_3/arm64-v8a/libssl.so)
else()
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Qt6::DBus
        Qt6::Widgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_compile_options(${PROJECT_NAME} PRIVATE -fexceptions)

if(MPV_AVAILABLE)
    target_link_libraries(${PROJECT_NAME} mpv)
    add_definitions(-DMPV_AVAILABLE)
    target_compile_definitions(${PROJECT_NAME} PUBLIC MPV_AVAILABLE)
endif()

set(Taglib_LIBRARIES
    TagLib::tag)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    MauiKit4
    MauiKit4::FileBrowsing
    Qt6::Network
    Qt6::Core
    Qt6::Quick
    Qt6::Qml
    Qt6::Multimedia
    KF6::CoreAddons
    KF6::I18n
    ${AVUTIL_LIBRARIES}
    ${AVFILTER_LIBRARIES}
    ${AVFORMAT_LIBRARIES}
    ${AVCODEC_LIBRARIES}
    ${SWSCALE_LIBRARIES}
    ${Taglib_LIBRARIES})

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install (TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.kde.clip.desktop DESTINATION ${KDE_INSTALL_APPDIR})
    #TODO: port to ecm_install_icons()
    install(FILES assets/clip.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()

qt_finalize_target(${PROJECT_NAME})
