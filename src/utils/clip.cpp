#include "clip.h"
#include <QDesktopServices>
#include <QSettings>
#include <MauiKit3/FileBrowsing/fmstatic.h>

Clip::Clip(QObject *parent) : QObject(parent)
{
    //create a screenshots folder
#ifdef MPV_AVAILABLE
    FMStatic::createDir(FMStatic::PicturesPath, "screenshots");
#endif
}

const QStringList Clip::getSourcePaths()
{
    static const QStringList defaultSources  = {FMStatic::VideosPath, FMStatic::DownloadsPath};

    QSettings settings;
    settings.beginGroup("Settings");
    const auto sources  = settings.value("Sources", defaultSources).toStringList();
    settings.endGroup();

    qDebug()<< "SOURCES" << sources;
    return sources;
}

void Clip::saveSourcePath(const QStringList &paths)
{
    auto sources = getSourcePaths();

    sources << paths;
    sources.removeDuplicates();

    qDebug()<< "Saving new sources" << sources;
    QSettings settings;
    settings.beginGroup("Settings");
    settings.setValue("Sources", sources);
    settings.endGroup();

}

void Clip::removeSourcePath(const QString &path)
{
    auto sources = getSourcePaths();
    sources.removeOne(path);

    QSettings settings;
    settings.beginGroup("Settings");
    settings.setValue("Sources", sources);
    settings.endGroup();
}

bool Clip::mpvAvailable() const
{
#ifdef MPV_AVAILABLE
    return true;
#else
    return false;
#endif
}

QVariantList Clip::sourcesModel() const
{
    QVariantList res;
    const auto sources = getSourcePaths();
    return std::accumulate(sources.constBegin(), sources.constEnd(), res, [](QVariantList &res, const QString &url)
    {
        res << FMStatic::getFileInfo(url);
        return res;
    });
}

QStringList Clip::sources() const
{
    return getSourcePaths();
}

void Clip::openVideos(const QList<QUrl> &urls)
{
    emit this->openUrls(QUrl::toStringList(urls));
}

void Clip::refreshCollection()
{
    const auto sources = getSourcePaths();
    qDebug()<< "getting default sources to look up" << sources;
}

void Clip::showInFolder(const QStringList &urls)
{
    for(const auto &url : urls)
        QDesktopServices::openUrl(FMStatic::fileDir(url));
}

void Clip::addSources(const QStringList &paths)
{
    saveSourcePath(paths);
    emit sourcesChanged();
}

void Clip::removeSources(const QString &path)
{
    removeSourcePath(path);
    emit sourcesChanged();
}
