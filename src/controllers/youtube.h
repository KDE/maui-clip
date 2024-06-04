#pragma once

#include <QObject>
#include <QUrl>
#include <QByteArray>

#include <MauiKit4/Core/fmh.h>

class YouTube : public QObject
{
    Q_OBJECT

  public:
    explicit YouTube(QObject *parent = nullptr);

    void getQuery(const QString &query, const int &limit = 5);
    bool packQueryResults(const QByteArray &array);
    void getId(const QString &results);
    void getUrl(const QString &id);

    void setKey(const QString &key);
    QString getKey() const;

    static QUrl fromUserInput(const QString &userInput);
private:
    QString KEY;
    const QString API = "https://www.googleapis.com/youtube/v3/search?";

Q_SIGNALS:
    void queryResultsReady(FMH::MODEL_LIST res);
};
