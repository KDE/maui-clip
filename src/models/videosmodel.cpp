#include "videosmodel.h"
#include <QFileSystemWatcher>
#include <QDebug>
#include <MauiKit/FileBrowsing/tagging.h>
#include <MauiKit/FileBrowsing/fmstatic.h>
#include <MauiKit/FileBrowsing/fileloader.h>

static FMH::MODEL videoData(const QUrl &url)
{
    FMH::MODEL model;
    model= FMStatic::getFileInfoModel(url);
    model.insert(FMH::MODEL_KEY::PREVIEW, "image://preview/"+url.toString());
    return model;
}

VideosModel::VideosModel(QObject *parent) : MauiList(parent)
  , m_fileLoader(new FMH::FileLoader(this))
  , m_watcher (new QFileSystemWatcher(this))
  , m_autoReload(true)
  , m_autoScan(true)
  , m_recursive (true)
{
    qDebug()<< "CREATING GALLERY LIST";

    m_fileLoader->informer = &videoData;
    connect(m_fileLoader, &FMH::FileLoader::finished,[this](FMH::MODEL_LIST items)
    {
        qDebug() << "Items finished" << items.size();
        emit this->filesChanged();
    });

    connect(m_fileLoader, &FMH::FileLoader::itemsReady,[this](FMH::MODEL_LIST items)
    {
        emit this->preListChanged();
        this-> list << items;
        emit this->postListChanged();
        emit this->countChanged();
    });

    connect(m_fileLoader, &FMH::FileLoader::itemReady,[this](FMH::MODEL item)
    {
        this->insertFolder(item[FMH::MODEL_KEY::SOURCE]);
    });

    connect(m_watcher, &QFileSystemWatcher::directoryChanged, [this](QString dir)
    {
        qDebug()<< "Dir changed" << dir;
        this->rescan();
        //        this->scan({QUrl::fromLocalFile(dir)}, m_recursive);
    });

    connect(m_watcher, &QFileSystemWatcher::fileChanged, [](QString file)
    {
        qDebug()<< "File changed" << file;
    });
}

const FMH::MODEL_LIST &VideosModel::items() const
{
    return this->list;
}

void VideosModel::setUrls(const QList<QUrl> &urls)
{
    qDebug()<< "setting urls"<< this->m_urls << urls;

    if(this->m_urls == urls)
        return;

    this->m_urls = urls;
    this->clear();
    emit this->urlsChanged();

    if(m_autoScan)
    {
        this->scan(m_urls, m_recursive, m_limit);
    }
}

QList<QUrl> VideosModel::urls() const
{
    return m_urls;
}

void VideosModel::setAutoScan(const bool &value)
{
    if(m_autoScan == value)
        return;

    m_autoScan = value;
    emit autoScanChanged();
}

bool VideosModel::autoScan() const
{
    return m_autoScan;
}

void VideosModel::setAutoReload(const bool &value)
{
    if(m_autoReload == value)
        return;

    m_autoReload = value;
    emit autoReloadChanged();
}

bool VideosModel::autoReload() const
{
    return m_autoReload;
}

QList<QUrl> VideosModel::folders() const
{
    return m_folders;
}

bool VideosModel::recursive() const
{
    return m_recursive;
}

int VideosModel::limit() const
{
    return m_limit;
}

QStringList VideosModel::files() const
{
    return FMH::modelToList(this->list, FMH::MODEL_KEY::URL);
}

void VideosModel::scan(const QList<QUrl> &urls, const bool &recursive, const int &limit)
{
    this->scanTags (extractTags (urls), limit);
    m_fileLoader->requestPath(urls, recursive, FMStatic::FILTER_LIST[FMStatic::FILTER_TYPE::VIDEO]);
}

void VideosModel::scanTags(const QList<QUrl> & urls, const int & limit)
{
    FMH::MODEL_LIST res;
    for(const auto &tagUrl : urls)
    {
        auto items = Tagging::getInstance ()->getUrls(tagUrl.toString ().replace ("tags:///", ""), true, limit, "video");

        for(const auto &item : items)
        {
            const auto url = QUrl(item.toMap ().value ("url").toString());
            if(FMH::fileExists(url))
                res << FMStatic::getFileInfoModel(url);
        }
    }

    emit this->preListChanged ();
    list << res;
    emit this->postListChanged ();
    emit countChanged();
}

void VideosModel::insertFolder(const QUrl &path)
{
    if(!m_folders.contains(path))
    {
        m_folders << path;

        if(m_autoReload)
        {
            this->m_watcher->addPath(path.toLocalFile());
        }

        emit foldersChanged();
    }
}

QList<QUrl> VideosModel::extractTags(const QList<QUrl> & urls)
{
    QList<QUrl> res;
    return std::accumulate(urls.constBegin (), urls.constEnd (), res, [](QList<QUrl> &list, const QUrl &url)
    {
        if(FMStatic::getPathType (url) == FMStatic::PATHTYPE_KEY::TAGS_PATH)
        {
            list << url;
        }

        return list;
    });
}

bool VideosModel::remove(const int &index)
{
    if (index >= this->list.size() || index < 0)
        return false;

    emit this->preItemRemoved(index);
    this->list.removeAt(index);
    emit this->postItemRemoved();
    emit this->countChanged();

    return true;
}

bool VideosModel::deleteAt(const int &index)
{
    if(index >= this->list.size() || index < 0)
        return false;

    emit this->preItemRemoved(index);
    auto item = this->list.takeAt(index);
    FMStatic::removeFiles ({item[FMH::MODEL_KEY::URL]});
    emit this->postItemRemoved();
    emit this->countChanged();

    return true;
}

void VideosModel::append(const QVariantMap &item)
{
    emit this->preItemAppended();
    this->list << FMH::toModel (item);
    emit this->postItemAppended();
    emit this->countChanged();
}

void VideosModel::appendUrl(const QString &url)
{
    emit this->preItemAppended();
    this->list << FMStatic::getFileInfoModel(QUrl::fromUserInput (url));
    emit this->postItemAppended();
    emit this->countChanged();
}

void VideosModel::clear()
{
    emit this->preListChanged();
    this->list.clear ();
    emit this->postListChanged();
    emit this->countChanged();

    this->m_folders.clear ();
    emit foldersChanged();
}

void VideosModel::rescan()
{
    this->clear();
    this->scan(m_urls, m_recursive, m_limit);
}

void VideosModel::reload()
{
    this->scan(m_urls, m_recursive, m_limit);
}

void VideosModel::setRecursive(bool recursive)
{
    if (m_recursive == recursive)
        return;

    m_recursive = recursive;
    emit recursiveChanged(m_recursive);
}

void VideosModel::setlimit(int limit)
{
    if (m_limit == limit)
        return;

    m_limit = limit;
    emit limitChanged(m_limit);
}
