/*
   Babe - tiny music player
   Copyright (C) 2017  Camilo Higuita
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

   */


#include "youtube.h"

#include <QUrl>
#include <QJsonObject>
#include <QJsonDocument>
#include <QVariantMap>

#include <MauiKit3/FileBrowsing/downloader.h>

YouTube::YouTube(QObject *parent) : QObject(parent)
{

}

void YouTube::getQuery(const QString &query, const int &limit)
{
    QUrl encodedQuery(query);
    encodedQuery.toEncoded(QUrl::FullyEncoded);

    auto url = this->API;

    url.append("q="+encodedQuery.toString());
    url.append(QString("&maxResults=%1&part=snippet").arg(QString::number(limit)));
    url.append("&key="+ this->KEY);

    qDebug()<< url;

    auto downloader = new FMH::Downloader;

    connect(downloader, &FMH::Downloader::dataReady, [this, downloader](QByteArray array)
    {
        this->packQueryResults(array);
        downloader->deleteLater();
    });

    downloader->getArray(url);
}

bool YouTube::packQueryResults(const QByteArray &array)
{
    QJsonParseError jsonParseError;
    QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError)
        return false;

    if (!jsonResponse.isObject())
        return false;

    QJsonObject mainJsonObject(jsonResponse.object());
    auto data = mainJsonObject.toVariantMap();
    auto items = data.value("items").toList();

    if(items.isEmpty()) return false;

    FMH::MODEL_LIST res;

    for(auto item : items)
    {
        auto itemMap = item.toMap().value("id").toMap();
        auto id = itemMap.value("videoId").toString();
        auto url = "https://www.youtube.com/embed/"+id;

        auto snippet = item.toMap().value("snippet").toMap();

        auto comment = snippet.value("description").toString();
        auto title = snippet.value("title").toString();
        auto artwork = snippet.value("thumbnails").toMap().value("high").toMap().value("url").toString();

        if(!id.isEmpty())
        {
            res <<   FMH::MODEL {
            {FMH::MODEL_KEY::ID, id},
            {FMH::MODEL_KEY::URL, url},
            {FMH::MODEL_KEY::LABEL, title},
            {FMH::MODEL_KEY::TITLE, title},
            {FMH::MODEL_KEY::THUMBNAIL, artwork},
            {FMH::MODEL_KEY::COMMENT, comment}
        };
        }
    }

    emit this->queryResultsReady(res);
    return true;
}

void YouTube::setKey(const QString &key)
{
    this->KEY = key;
}

QString YouTube::getKey() const
{
    return this->KEY;
}

