#include "youtubemodel.h"
#include "controllers/youtube.h"

YouTubeModel::YouTubeModel(QObject *parent) : MauiList(parent)
  , m_yt(new YouTube(this))
{
    connect(m_yt, &YouTube::queryResultsReady, this, &YouTubeModel::setList);
}

void YouTubeModel::componentComplete()
{
    connect(this, &YouTubeModel::queryChanged, this, &YouTubeModel::request);
    this->request(m_query);
}

const FMH::MODEL_LIST &YouTubeModel::items() const
{
    return m_list;
}

QString YouTubeModel::query() const
{
    return m_query;
}

QString YouTubeModel::key() const
{
    return m_key;
}

int YouTubeModel::limit() const
{
    return m_limit;
}

void YouTubeModel::setQuery(QString query)
{
    if (m_query == query)
        return;

    m_query = query;
    emit queryChanged(m_query);
}

void YouTubeModel::setKey(QString key)
{
    if (m_key == key)
        return;

    m_key = key;
    emit keyChanged(m_key);
}

void YouTubeModel::setLimit(int limit)
{
    if (m_limit == limit)
        return;

    m_limit = limit;
    emit limitChanged(m_limit);
}

void YouTubeModel::setList(const FMH::MODEL_LIST &data)
{
    this->m_list.clear();
    emit this->preListChanged();

    this->m_list = data;

    emit this->postListChanged();
}

void YouTubeModel::request(const QString &query)
{
    if(query.isEmpty())
        return;

    this->m_yt->setKey(m_key);
    this->m_yt->getQuery(query, m_limit);
}
