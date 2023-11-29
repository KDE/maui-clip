#pragma once

#include <QObject>

#include <MauiKit3/Core/mauilist.h>
#include "utils/clip.h"

#define CINEMA_QUERY_MAX_LIMIT 20000

namespace FMH
{
class FileLoader;
}

class QFileSystemWatcher;
class VideosModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QStringList urls READ urls WRITE setUrls NOTIFY urlsChanged RESET resetUrls)
    Q_PROPERTY(QList<QUrl> folders READ folders NOTIFY foldersChanged FINAL)
    Q_PROPERTY(bool recursive READ recursive WRITE setRecursive NOTIFY recursiveChanged)
    Q_PROPERTY(bool autoScan READ autoScan WRITE setAutoScan NOTIFY autoScanChanged)
    Q_PROPERTY(bool autoReload READ autoReload WRITE setAutoReload NOTIFY autoReloadChanged)
    Q_PROPERTY(int limit READ limit WRITE setlimit NOTIFY limitChanged)
    Q_PROPERTY(QStringList files READ files NOTIFY filesChanged FINAL)

public:
    explicit VideosModel(QObject *parent = nullptr);

    const FMH::MODEL_LIST &items() const override final;

    void setUrls(const QStringList &urls);
    QStringList urls() const;
    void resetUrls();

    void setAutoScan(const bool &value);
    bool autoScan() const;

    void setAutoReload(const bool &value);
    bool autoReload() const;

    QList<QUrl> folders() const;

    bool recursive() const;

    int limit() const;
    QStringList files() const;

private:
    FMH::FileLoader *m_fileLoader;
    QFileSystemWatcher *m_watcher;

    QStringList m_urls;
    QList<QUrl> m_folders;
    bool m_autoReload;
    bool m_autoScan;

    FMH::MODEL_LIST list;

    void scan(const QStringList &urls, const bool &recursive = true, const int &limit = CINEMA_QUERY_MAX_LIMIT);

    void insert(const FMH::MODEL_LIST &items);

    void insertFolder(const QUrl &path);

    bool m_recursive;

    int m_limit = CINEMA_QUERY_MAX_LIMIT;

Q_SIGNALS:
    void urlsChanged();
    void foldersChanged();
    void autoReloadChanged();
    void autoScanChanged();

    void recursiveChanged(bool recursive);

    void limitChanged(int limit);

    void filesChanged();

public Q_SLOTS:
    bool remove(const int &index);
    bool deleteAt(const int &index);

    void append(const QVariantMap &item);
    void appendUrl(const QString &url);
    //    void appendAt(const QString &url, const int &pos);

    void clear();
    void rescan();

    void setRecursive(bool recursive);
    void setlimit(int limit);

    // QQmlParserStatus interface
public:
    void classBegin() override final;
    void componentComplete() override final;
};
