/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

//#include "_debug.h"
#include "mpvobject.h"
//#include "application.h"
//#include "playbacksettings.h"
//#include "playlistitem.h"
#include "track.h"

#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QObject>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QProcess>
#include <QQuickWindow>
#include <QStandardPaths>
#include <QtGlobal>
#include <cstring>

void on_mpv_redraw(void *ctx)
{
    QMetaObject::invokeMethod(static_cast<MpvObject*>(ctx), "update", Qt::QueuedConnection);
}

static void *get_proc_address_mpv(void *ctx, const char *name)
{
    Q_UNUSED(ctx)

    QOpenGLContext *glctx = QOpenGLContext::currentContext();
    if (!glctx) return nullptr;

    return reinterpret_cast<void *>(glctx->getProcAddress(QByteArray(name)));
}

MpvRenderer::MpvRenderer(MpvObject *new_obj)
    : obj{new_obj}
{}

void MpvRenderer::render()
{
    obj->window()->beginExternalCommands();

    QOpenGLFramebufferObject *fbo = framebufferObject();
    mpv_opengl_fbo mpfbo;
    mpfbo.fbo = static_cast<int>(fbo->handle());
    mpfbo.w = fbo->width();
    mpfbo.h = fbo->height();
    mpfbo.internal_format = 0;

    mpv_render_param params[] = {
        // Specify the default framebuffer (0) as target. This will
        // render onto the entire screen. If you want to show the video
        // in a smaller rectangle or apply fancy transformations, you'll
        // need to render into a separate FBO and draw it manually.
        {MPV_RENDER_PARAM_OPENGL_FBO, &mpfbo},
        {MPV_RENDER_PARAM_INVALID, nullptr}
    };
    // See render_gl.h on what OpenGL environment mpv expects, and
    // other API details.
    mpv_render_context_render(obj->mpv_gl, params);

    obj->window()->endExternalCommands();
}

QOpenGLFramebufferObject * MpvRenderer::createFramebufferObject(const QSize &size)
{
    // init mpv_gl:
    if (!obj->mpv_gl)
    {
        mpv_opengl_init_params gl_init_params;
        gl_init_params.get_proc_address = get_proc_address_mpv;
        gl_init_params.get_proc_address_ctx = nullptr;
        mpv_render_param params[]{
            {MPV_RENDER_PARAM_API_TYPE, const_cast<char *>(MPV_RENDER_API_TYPE_OPENGL)},
            {MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &gl_init_params},
            {MPV_RENDER_PARAM_INVALID, nullptr}
        };

        if (mpv_render_context_create(&obj->mpv_gl, obj->mpv, params) < 0)
            throw std::runtime_error("failed to initialize mpv GL context");
        mpv_render_context_set_update_callback(obj->mpv_gl, on_mpv_redraw, obj);
        Q_EMIT obj->ready();
    }

    return QQuickFramebufferObject::Renderer::createFramebufferObject(size);
}

MpvObject::MpvObject(QQuickItem * parent)
    : QQuickFramebufferObject(parent)
    , mpv{mpv_create()}
    , mpv_gl(nullptr)
    , m_audioTracksModel(new TracksModel)
    , m_subtitleTracksModel(new TracksModel)
    //    , m_playlistModel(new PlayListModel)
{
    if (!mpv)
        throw std::runtime_error("could not create mpv context");

    //    setProperty("terminal", "yes");
    //    setProperty("msg-level", "all=v");

    if (m_hardwareDecoding) {
        setProperty("hwdec", "yes");
    } else {
        setProperty("hwdec", "no");
    }

    setProperty("screenshot-template", "%x/screenshots/%n");
    setProperty("sub-auto", "exact");

    mpv_observe_property(mpv, 0, "media-title", MPV_FORMAT_STRING);
    mpv_observe_property(mpv, 0, "time-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "time-remaining", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "duration", MPV_FORMAT_DOUBLE);
    mpv_observe_property(mpv, 0, "volume", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "pause", MPV_FORMAT_FLAG);
    mpv_observe_property(mpv, 0, "chapter", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "aid", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "sid", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "secondary-sid", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "contrast", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "brightness", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "gamma", MPV_FORMAT_INT64);
    mpv_observe_property(mpv, 0, "saturation", MPV_FORMAT_INT64);

    QString configPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);
    QString watchLaterPath = configPath.append("/georgefb/watch-later");
    setProperty("watch-later-directory", watchLaterPath);
    QDir watchLaterDir(watchLaterPath);
    if (!watchLaterDir.exists()) {
        QDir().mkdir(watchLaterPath);
    }

    if (mpv_initialize(mpv) < 0)
        throw std::runtime_error("could not initialize mpv context");

    mpv_set_wakeup_callback(mpv, MpvObject::mpvEvents, this);

    connect(this, &MpvObject::fileLoaded,
            this, &MpvObject::loadTracks);

    connect(this, &MpvObject::positionChanged, this, [this]() {
        int pos = getProperty("time-pos").toInt();
        double duration = getProperty("duration").toDouble();
        if (!m_secondsWatched.contains(pos)) {
            m_secondsWatched << pos;
            setWatchPercentage(m_secondsWatched.count() * 100 / duration);
        }
    });

    connect(this, &MpvObject::paused, [this]()
    {
        this->setPlaybackState(QMediaPlayer::PausedState);
    });

    connect(this, &MpvObject::playing, [this]()
    {
        this->setPlaybackState(QMediaPlayer::PlayingState);
    });

    connect(this, &MpvObject::stopped, [this]()
    {
        this->setPlaybackState(QMediaPlayer::StoppedState);
    });
}

MpvObject::~MpvObject()
{
    // only initialized if something got drawn
    if (mpv_gl) {
        mpv_render_context_free(mpv_gl);
    }
    mpv_terminate_destroy(mpv);
}

//PlayListModel *MpvObject::playlistModel()
//{
//    return m_playlistModel;
//}

//void MpvObject::setPlaylistModel(PlayListModel *model)
//{
//    m_playlistModel = model;
//}

QString MpvObject::mediaTitle()
{
    return getProperty("media-title").toString();
}

double MpvObject::position()
{
    return getProperty("time-pos").toDouble()*1000;
}

void MpvObject::setPosition(double value)
{
    if (value == position()) {
        return;
    }
    setProperty("time-pos", value);
    Q_EMIT positionChanged();
}

double MpvObject::remaining()
{
    return getProperty("time-remaining").toDouble();
}

double MpvObject::duration()
{
    return getProperty("duration").toDouble()*1000;
}

int MpvObject::volume()
{
    return getProperty("volume").toInt();
}

void MpvObject::setVolume(int value)
{
    if (value == volume()) {
        return;
    }
    setProperty("volume", value);
    Q_EMIT volumeChanged();
}

int MpvObject::chapter()
{
    return getProperty("chapter").toInt();
}

void MpvObject::setChapter(int value)
{
    if (value == chapter()) {
        return;
    }
    setProperty("chapter", value);
    Q_EMIT chapterChanged();
}

int MpvObject::audioId()
{
    return getProperty("aid").toInt();
}

void MpvObject::setAudioId(int value)
{
    if (value == audioId()) {
        return;
    }
    setProperty("aid", value);
    Q_EMIT audioIdChanged();
}

int MpvObject::subtitleId()
{
    return getProperty("sid").toInt();
}

void MpvObject::setSubtitleId(int value)
{
    if (value == subtitleId()) {
        return;
    }
    setProperty("sid", value);
    Q_EMIT subtitleIdChanged();
}

int MpvObject::secondarySubtitleId()
{
    return getProperty("secondary-sid").toInt();
}

void MpvObject::setSecondarySubtitleId(int value)
{
    if (value == secondarySubtitleId()) {
        return;
    }
    setProperty("secondary-sid", value);
    Q_EMIT secondarySubtitleIdChanged();
}

int MpvObject::contrast()
{
    return getProperty("contrast").toInt();
}

void MpvObject::setContrast(int value)
{
    if (value == contrast()) {
        return;
    }
    setProperty("contrast", value);
    Q_EMIT contrastChanged();
}

int MpvObject::brightness()
{
    return getProperty("brightness").toInt();
}

void MpvObject::setBrightness(int value)
{
    if (value == brightness()) {
        return;
    }
    setProperty("brightness", value);
    Q_EMIT brightnessChanged();
}

int MpvObject::gamma()
{
    return getProperty("gamma").toInt();
}

void MpvObject::setGamma(int value)
{
    if (value == gamma()) {
        return;
    }
    setProperty("gamma", value);
    Q_EMIT gammaChanged();
}

int MpvObject::saturation()
{
    return getProperty("saturation").toInt();
}

void MpvObject::setSaturation(int value)
{
    if (value == saturation()) {
        return;
    }
    setProperty("saturation", value);
    Q_EMIT saturationChanged();
}

double MpvObject::watchPercentage()
{
    return m_watchPercentage;
}

void MpvObject::setWatchPercentage(double value)
{
    if (m_watchPercentage == value) {
        return;
    }
    m_watchPercentage = value;
    Q_EMIT watchPercentageChanged();
}

bool MpvObject::hwDecoding()
{
    if (getProperty("hwdec") == "yes") {
        return true;
    } else {
        return false;
    }
}

void MpvObject::setHWDecoding(bool value)
{
    if (value) {
        setProperty("hwdec", "yes");
    } else  {
        setProperty("hwdec", "no");
    }
    Q_EMIT hwDecodingChanged();
}

QQuickFramebufferObject::Renderer *MpvObject::createRenderer() const
{
    // window()->setPersistentGraphics(true);
    window()->setPersistentSceneGraph(true);
    return new MpvRenderer(const_cast<MpvObject *>(this));
}

void MpvObject::mpvEvents(void *ctx)
{
    QMetaObject::invokeMethod(static_cast<MpvObject*>(ctx), "eventHandler", Qt::QueuedConnection);
}

void MpvObject::eventHandler()
{
    while (mpv) {
        mpv_event *event = mpv_wait_event(mpv, 0);
        if (event->event_id == MPV_EVENT_NONE) {
            break;
        }
        switch (event->event_id) {

        case MPV_EVENT_START_FILE:
            //               clearTrackState();
            //               Q_EMIT sourceChanged();
            setStatus(QMediaPlayer::LoadingMedia);
            break;

        case MPV_EVENT_SEEK:
            setStatus(QMediaPlayer::BufferingMedia);
            break;

        case MPV_EVENT_PLAYBACK_RESTART: {
            bool paused = this->getProperty("pause").toBool();
            if (paused)
                Q_EMIT this->paused();
            else
                Q_EMIT this->playing();
            break;
        }

        case MPV_EVENT_FILE_LOADED: {
            Q_EMIT fileLoaded();
            setStatus(QMediaPlayer::LoadedMedia);
            Q_EMIT this->playing();
            break;
        }

        case MPV_EVENT_END_FILE: {
            auto prop = (mpv_event_end_file *)event->data;
            if (prop->reason == MPV_END_FILE_REASON_EOF ||
                    prop ->reason == MPV_END_FILE_REASON_ERROR) {
                Q_EMIT endOfFile();
                setStatus(QMediaPlayer::EndOfMedia);
                Q_EMIT this->stopped();
            }
            break;
        }
        case MPV_EVENT_PROPERTY_CHANGE: {
            mpv_event_property *prop = (mpv_event_property *)event->data;

            if (strcmp(prop->name, "time-pos") == 0) {
                if (prop->format == MPV_FORMAT_DOUBLE) {
                    Q_EMIT positionChanged();
                }
            } else if (strcmp(prop->name, "media-title") == 0) {
                if (prop->format == MPV_FORMAT_STRING) {
                    Q_EMIT mediaTitleChanged();
                }
            } else if (strcmp(prop->name, "time-remaining") == 0) {
                if (prop->format == MPV_FORMAT_DOUBLE) {
                    Q_EMIT remainingChanged();
                }
            } else if (strcmp(prop->name, "duration") == 0) {
                if (prop->format == MPV_FORMAT_DOUBLE) {
                    Q_EMIT durationChanged();
                }
            } else if (strcmp(prop->name, "volume") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT volumeChanged();
                }
            } else if (strcmp(prop->name, "pause") == 0) {

                if (prop->format == MPV_FORMAT_FLAG) {
                    int pause = *(int *)prop->data;
                    bool paused = pause == 1;
                    if (paused)
                        Q_EMIT this->paused();
                    else {
                        if(this->getProperty("core-idle").toBool())
                        {
                            Q_EMIT this->stopped();
                            setStatus(QMediaPlayer::NoMedia);
                        }
                        else
                        {
                            Q_EMIT this->playing();
                            Q_EMIT this->stopped();
                            setStatus(QMediaPlayer::LoadedMedia);
                        }
                    }
                }

            } else if (strcmp(prop->name, "chapter") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT chapterChanged();
                }
            } else if (strcmp(prop->name, "aid") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT audioIdChanged();
                }
            } else if (strcmp(prop->name, "sid") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT subtitleIdChanged();
                } else {
                    Q_EMIT subtitleIdChanged();
                }
            } else if (strcmp(prop->name, "secondary-sid") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT secondarySubtitleIdChanged();
                } else {
                    Q_EMIT secondarySubtitleIdChanged();
                }
            } else if (strcmp(prop->name, "contrast") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT contrastChanged();
                }
            } else if (strcmp(prop->name, "brightness") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT brightnessChanged();
                }
            } else if (strcmp(prop->name, "gamma") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT gammaChanged();
                }
            } else if (strcmp(prop->name, "saturation") == 0) {
                if (prop->format == MPV_FORMAT_INT64) {
                    Q_EMIT saturationChanged();
                }
            }
            break;
        }

        case MPV_EVENT_LOG_MESSAGE: {
            struct mpv_event_log_message *msg = (struct mpv_event_log_message *)event->data;
            qDebug() << "[" << msg->prefix << "] " << msg->level << ": " << msg->text;

            if (msg->log_level == MPV_LOG_LEVEL_ERROR) {
                //                    lastErrorString = QString::fromUtf8(msg->text);
                Q_EMIT error(QString::fromUtf8(msg->text));
                setStatus(QMediaPlayer::InvalidMedia);

            }

            break;
        }

        default: ;
            // Ignore uninteresting or unknown events.
        }
    }
}

void MpvObject::loadTracks()
{
    m_subtitleTracks.clear();
    m_audioTracks.clear();

    auto none = new Track();
    none->setId(0);
    none->setTitle("None");
    m_subtitleTracks.insert(0, none);

    const QList<QVariant> tracks = getProperty("track-list").toList();
    int subIndex = 1;
    int audioIndex = 0;
    for (const auto &track : tracks) {
        const auto t = track.toMap();
        if (track.toMap()["type"] == "sub") {
            auto track = new Track();
            track->setCodec(t["codec"].toString());
            track->setType(t["type"].toString());
            track->setDefaut(t["default"].toBool());
            track->setDependent(t["dependent"].toBool());
            track->setForced(t["forced"].toBool());
            track->setId(t["id"].toLongLong());
            track->setSrcId(t["src-id"].toLongLong());
            track->setFfIndex(t["ff-index"].toLongLong());
            track->setLang(t["lang"].toString());
            track->setTitle(t["title"].toString());
            track->setIndex(subIndex);

            m_subtitleTracks.insert(subIndex, track);
            subIndex++;
        }
        if (track.toMap()["type"] == "audio") {
            auto track = new Track();
            track->setCodec(t["codec"].toString());
            track->setType(t["type"].toString());
            track->setDefaut(t["default"].toBool());
            track->setDependent(t["dependent"].toBool());
            track->setForced(t["forced"].toBool());
            track->setId(t["id"].toLongLong());
            track->setSrcId(t["src-id"].toLongLong());
            track->setFfIndex(t["ff-index"].toLongLong());
            track->setLang(t["lang"].toString());
            track->setTitle(t["title"].toString());
            track->setIndex(audioIndex);

            m_audioTracks.insert(audioIndex, track);
            audioIndex++;
        }
    }
    m_subtitleTracksModel->setTracks(m_subtitleTracks);

    qDebug() << "Audio tracks"  << m_audioTracks << m_audioTracks.size();

    m_audioTracksModel->setTracks(m_audioTracks);

    Q_EMIT audioTracksModelChanged();
    Q_EMIT subtitleTracksModelChanged();
}

void MpvObject::play()
{
    this->setProperty("pause", false);
}

void MpvObject::stop()
{
    this->command(QStringList () << "stop" << "");
    Q_EMIT this->stopped();
}

void MpvObject::pause()
{
    this->setProperty("pause", true);
}

void MpvObject::seek(const double &value)
{
    command(QStringList() << "seek" << QString::number(value/1000) << "absolute");
}

void MpvObject::setHardwareDecoding(bool hardwareDecoding)
{
    if (m_hardwareDecoding == hardwareDecoding)
        return;

    m_hardwareDecoding = hardwareDecoding;

    if (m_hardwareDecoding) {
        setProperty("hwdec", "yes");
    } else {
        setProperty("hwdec", "no");
    }

    Q_EMIT hardwareDecodingChanged(m_hardwareDecoding);
}

TracksModel *MpvObject::subtitleTracksModel() const
{
    return m_subtitleTracksModel;
}

TracksModel *MpvObject::audioTracksModel() const
{
    return m_audioTracksModel;
}

int MpvObject::setProperty(const QString &name, const QVariant &value)
{
    return mpv::qt::set_property(mpv, name, value);
}

void MpvObject::setSource(QUrl url)
{
    if (m_source == url)
        return;

    m_source = url;

    if(m_autoPlay)
    {
        this->playUrl();
    }

    Q_EMIT sourceChanged(m_source);
}

void MpvObject::setAutoPlay(bool autoPlay)
{
    if (m_autoPlay == autoPlay)
        return;

    m_autoPlay = autoPlay;
    Q_EMIT autoPlayChanged(m_autoPlay);
}

QVariant MpvObject::getProperty(const QString &name)
{
    auto value = mpv::qt::get_property(mpv, name);
    return value;
}

QVariant MpvObject::command(const QVariant &params)
{
    return mpv::qt::command(mpv, params);
}

QUrl MpvObject::source() const
{
    return m_source;
}

bool MpvObject::autoPlay() const
{
    return m_autoPlay;
}

void MpvObject::setPlaybackState(const QMediaPlayer::PlaybackState &state)
{
    m_playbackState = state;
    Q_EMIT this->playbackStateChanged(m_playbackState);
}

void MpvObject::setStatus(const QMediaPlayer::MediaStatus  &status)
{
    m_status = status;
    Q_EMIT this->statusChanged(m_status);
}

QMediaPlayer::PlaybackState MpvObject::getPlaybackState() const
{
    return m_playbackState;
}

QMediaPlayer::MediaStatus MpvObject::getStatus() const
{
    return m_status;
}

bool MpvObject::hardwareDecoding() const
{
    return m_hardwareDecoding;
}

void MpvObject::playUrl()
{
    if(!m_source.isEmpty() && m_source.isValid())
    {
        qDebug() << "request play file" << m_source;

        if(m_source.isLocalFile())
            command(QStringList{"loadfile", m_source.toLocalFile()});
        else
            command(QStringList{"loadfile", m_source.toString()});
    }

    if (m_playbackState == QMediaPlayer::PausedState)
        play();
}
