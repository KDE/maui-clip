#ifndef CLIP_H
#define CLIP_H

#include <QDebug>

#include <MauiKit3/Core/utils.h>
#include <MauiKit3/Core/fmh.h>
#include <MauiKit3/FileBrowsing/fmstatic.h>

class Clip : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList sourcesModel READ sourcesModel NOTIFY sourcesChanged FINAL)
    Q_PROPERTY(QStringList sources READ sources NOTIFY sourcesChanged FINAL)
    Q_PROPERTY(bool mpvAvailable READ mpvAvailable CONSTANT FINAL)

public:
    static Clip * instance()
    {
        static Clip clip;
        return &clip;
    }

    Clip(const Clip &) = delete;
    Clip &operator=(const Clip &) = delete;
    Clip(Clip &&) = delete;
    Clip &operator=(Clip &&) = delete;

    bool mpvAvailable() const;

public slots:
    QVariantList sourcesModel() const;
    QStringList sources() const;

    void addSources(const QStringList &paths);
    void removeSources(const QString &path);

    void openVideos(const QList<QUrl> &urls);
    void refreshCollection();
    /*File actions*/
    static void showInFolder(const QStringList &urls);

private:
    explicit Clip(QObject* parent = nullptr);

    inline static const QStringList getSourcePaths()
    {
        static const QStringList defaultSources  = {FMStatic::VideosPath, FMStatic::DownloadsPath};
        const auto sources = UTIL::loadSettings("Sources", "Settings", defaultSources).toStringList();
        qDebug()<< "SOURCES" << sources;
        return sources;
    }

    inline static void saveSourcePath(QStringList const& paths)
    {
        auto sources = getSourcePaths();

        sources << paths;
        sources.removeDuplicates();

        qDebug()<< "Saving new sources" << sources;
        UTIL::saveSettings("Sources", sources, "Settings");
    }

    inline static void removeSourcePath(const QString &path)
    {
        auto sources = getSourcePaths();
        sources.removeOne(path);

        UTIL::saveSettings("Sources", sources, "Settings");
    }

signals:
    void refreshViews(QVariantMap tables);
    void openUrls(QStringList urls);
    void sourcesChanged();
};

#endif // CLIP_H
