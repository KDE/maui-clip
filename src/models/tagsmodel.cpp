#include "tagsmodel.h"

#include <MauiKit/FileBrowsing/fmstatic.h>
#include <MauiKit/FileBrowsing/tagging.h>

#include <KI18n/KLocalizedString>

TagsModel::TagsModel(QObject *parent) : MauiList(parent)
{    
    m_quickPlaces << QVariantMap{{"icon", "love"}, {"path", "tags:///fav"}, {"label", i18n("Favorites")}};
      m_quickPlaces << QVariantMap{{"icon", "folder-download"}, {"path", FMStatic::DownloadsPath}, {"label", i18n("Downloads")}};
      m_quickPlaces << QVariantMap{{"icon", "folder-videos"}, {"path", FMStatic::VideosPath}, {"label", i18n("Videos")}};
//      m_quickPlaces << QVariantMap{{"icon", "org.gnome.Screenshot-symbolic"}, {"path", screenshotsPath().toString()}, {"label", i18n("Screenshots")}};
      m_quickPlaces << QVariantMap{{"icon", "view-list-icons"}, {"path", "collection:///"}, {"label", i18n("Collection")}};

    connect(Tagging::getInstance(), &Tagging::tagged, [this](QVariantMap tag) {
        emit this->preItemAppended();
        auto item = FMH::toModel(tag);

        item[FMH::MODEL_KEY::PATH] = "tags:///"+item[FMH::MODEL_KEY::TAG];
        item[FMH::MODEL_KEY::TYPE] = i18n("Tags");
        this->list << item;
        emit this->postItemAppended();
    });
}

void TagsModel::componentComplete()
{
    this->setList();
}

QVariantList TagsModel::quickPlaces() const
{
    return m_quickPlaces;
}

const FMH::MODEL_LIST &TagsModel::items() const
{
    return this->list;
}

void TagsModel::setList()
{
    emit this->preListChanged();
    this->list << this->tags();
    emit this->postListChanged();
    emit countChanged();
}

FMH::MODEL_LIST TagsModel::tags()
{
    FMH::MODEL_LIST res;
    const auto tags = Tagging::getInstance()->getUrlsTags(true);

    return std::accumulate(tags.constBegin(), tags.constEnd(), res, [this](FMH::MODEL_LIST &list, const QVariant &item) {
        auto tag = FMH::toModel(item.toMap());
//        packPreviewImages(tag);
        tag[FMH::MODEL_KEY::PATH] = "tags:///"+tag[FMH::MODEL_KEY::TAG];
        tag[FMH::MODEL_KEY::TYPE] = i18n("Tags");
        list << tag;
        return list;
    });
}

void TagsModel::packPreviewImages(FMH::MODEL &tag)
{
    const auto urls = Tagging::getInstance()->getTagUrls(tag[FMH::MODEL_KEY::TAG], {}, true, 4, "video");
    tag[FMH::MODEL_KEY::PREVIEW] = QUrl::toStringList(urls).join(",");
}

