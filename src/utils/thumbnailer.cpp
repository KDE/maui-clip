#include "thumbnailer.h"

#include <QVideoFrame>
#include <QMediaPlayer>
#include <QImage>
#include <QUrl>
#include <QObject>
#include <QVideoSurfaceFormat>

QQuickImageResponse *Thumbnailer::requestImageResponse(const QString &id, const QSize &requestedSize)
{
    AsyncImageResponse *response = new AsyncImageResponse(id, requestedSize);
    return response;
}

AsyncImageResponse::AsyncImageResponse(const QString &id, const QSize &requestedSize)
    : m_id(id)
    , m_requestedSize(requestedSize)
{
//    auto player = new QMediaPlayer;
    auto surface = new Surface();
//    player->setVideoOutput(surface);

    connect(surface, &Surface::previewReady, [this](QImage img)
    {
       qDebug() << "image Ready" << img.height();
       m_image = img;
       emit this->finished();
//       player->stop();
//       player->deleteLater();
    });

    surface->request();

//    connect(job, &KIO::PreviewJob::failed, [this](KFileItem) {
//        m_error = "Thumbnail Previewer job failed";
//        this->cancel();
//        emit this->finished();
//    });
//  player->setMuted(true);
//  player->setPosition(player->duration()/2);
//    player->setMedia(QUrl::fromUserInput(id));
}

QQuickTextureFactory *AsyncImageResponse::textureFactory() const
{
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

QString AsyncImageResponse::errorString() const
{
    return m_error;
}


Surface::Surface(QObject *p) : QObject(p)
{

}

void Surface::request()
{
    QImage image("/home/camilo/Coding/qml/surf/logo.png");
    emit this->previewReady(image);
}


