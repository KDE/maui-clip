#include <QCommandLineParser>

#include <QDate>
#include <QDirIterator>

#include <QFileInfo>
#include <QIcon>

#include <QQmlApplicationEngine>

#include <KI18n/KLocalizedString>

#include <MauiKit/Core/mauiapp.h>
#include <MauiKit/FileBrowsing/fmstatic.h>

#ifdef MPV_AVAILABLE
#include "backends/mpv/mpvobject.h"
#endif

#include "models/videosmodel.h"
#include "models/tagsmodel.h"
#include "models/youtubemodel.h"

#include "utils/clip.h"
#include "../clip_version.h"

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#define CLIP_URI "org.maui.clip"

static const  QList<QUrl>  getFolderVideos(const QString &path)
{
    QList<QUrl> urls;

    if (QFileInfo(path).isDir())
    {
        QDirIterator it(path, FMStatic::FILTER_LIST[FMStatic::FILTER_TYPE::IMAGE], QDir::Files, QDirIterator::Subdirectories);
        while (it.hasNext())
            urls << QUrl::fromLocalFile(it.next());

    }else if (QFileInfo(path).isFile())
        urls << path;

    return urls;
}

static const QList<QUrl> openFiles(const QStringList &files)
{
    QList<QUrl>  urls;

    if(files.size()>1)
    {
        for(const auto &file : files)
            urls << QUrl::fromUserInput(file);
    }
    else if(files.size() == 1)
    {
        auto folder = QFileInfo(files.first()).dir().absolutePath();
        urls = getFolderVideos(folder);
        urls.removeOne(QUrl::fromLocalFile(files.first()));
        urls.insert(0,QUrl::fromLocalFile(files.first()));
    }

    return urls;
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif

#ifdef MPV_AVAILABLE
    // Qt sets the locale in the QGuiApplication constructor, but libmpv
    // requires the LC_NUMERIC category to be set to "C", so change it back.
    std::setlocale(LC_NUMERIC, "C");
#endif

    app.setOrganizationName("Maui");
    app.setWindowIcon(QIcon(":/img/assets/clip.svg"));

    MauiApp::instance()->setIconName("qrc:/img/assets/clip.svg");

    KLocalizedString::setApplicationDomain("clip");
    KAboutData about(QStringLiteral("clip"), i18n("Clip"), CLIP_VERSION_STRING, i18n("Browse and play your videos."),
                     KAboutLicense::LGPL_V3, i18n("© 2019-%1 Maui Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/clip");
    about.setBugAddress("https://invent.kde.org/maui/clip/-/issues");
    about.setOrganizationDomain(CLIP_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;

    about.setupCommandLine(&parser);
    parser.process(app);

    about.processCommandLine(&parser);

    const QStringList args = parser.positionalArguments();

    QList<QUrl> videos;
    if(!args.isEmpty())
        videos = openFiles(args);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url, args, &videos](QObject *obj, const QUrl &objUrl)
    {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);

        if(!videos.isEmpty())
            Clip::instance ()->openVideos(videos);

    }, Qt::QueuedConnection);

    qmlRegisterType<VideosModel>(CLIP_URI, 1, 0, "Videos");
    qmlRegisterType<TagsModel>(CLIP_URI, 1, 0, "Tags");
    qmlRegisterType<YouTubeModel>(CLIP_URI, 1, 0, "YouTube");
    qmlRegisterSingletonInstance<Clip>(CLIP_URI, 1, 0, "Clip", Clip::instance ());

#ifdef MPV_AVAILABLE
    qRegisterMetaType<TracksModel*>();
    qmlRegisterType<MpvObject>("mpv", 1, 0, "MpvObject");
    qmlRegisterType(QUrl("qrc:/views/player/MPVPlayer.qml"), CLIP_URI, 1, 0, "Video");
#else
    qmlRegisterType(QUrl("qrc:/views/player/Player.qml"), CLIP_URI, 1, 0, "Video");
#endif

    engine.load(url);

#ifdef Q_OS_MACOS
    //    MAUIMacOS::removeTitlebarFromWindow();
    //    MauiApp::instance()->setEnableCSD(true); //for now index can not handle cloud accounts
#endif

    return app.exec();
}
