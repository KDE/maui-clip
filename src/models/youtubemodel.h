#pragma once

#include <MauiKit3/Core/mauilist.h>
#include <QObject>

class YouTube;

class YouTubeModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
    Q_PROPERTY(int limit READ limit WRITE setLimit NOTIFY limitChanged)
    Q_PROPERTY(QString key READ key WRITE setKey NOTIFY keyChanged)

public:
    YouTubeModel(QObject * parent = nullptr);
    void componentComplete() override final;

    const FMH::MODEL_LIST &items() const override final;

    QString query() const;

    QString key() const;

    int limit() const;

public slots:
    void setQuery(QString query);

    void setKey(QString key);

    void setLimit(int limit);

Q_SIGNALS:
    void queryChanged(QString query);

    void keyChanged(QString key);

    void limitChanged(int limit);

private:
    YouTube *m_yt;

    FMH::MODEL_LIST m_list;

    void setList(const FMH::MODEL_LIST &data);
    void request(const QString &query);
    QString m_query;
    QString m_key;
    int m_limit = 10;
};
