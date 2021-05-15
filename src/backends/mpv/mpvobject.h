/*
 * SPDX-FileCopyrightText: 2020 George Florea Bănuș <georgefb899@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef MPVOBJECT_H
#define MPVOBJECT_H

#include <QtQuick/QQuickFramebufferObject>

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include "qthelper.h"
//#include "playlistmodel.h"
#include "tracksmodel.h"

#include <QMediaPlayer>

class MpvRenderer;
class Track;

class MpvObject : public QQuickFramebufferObject
{
    Q_OBJECT
    Q_PROPERTY(TracksModel* audioTracksModel READ audioTracksModel NOTIFY audioTracksModelChanged)
    Q_PROPERTY(TracksModel* subtitleTracksModel READ subtitleTracksModel NOTIFY subtitleTracksModelChanged)

    Q_PROPERTY(QUrl source
               READ source
               WRITE setSource
               NOTIFY sourceChanged)

    Q_PROPERTY(bool autoPlay
               READ autoPlay
               WRITE setAutoPlay
               NOTIFY autoPlayChanged)

    Q_PROPERTY(QMediaPlayer::State playbackState
               READ getPlaybackState
               NOTIFY playbackStateChanged)

    Q_PROPERTY(QMediaPlayer::MediaStatus status
               READ getStatus
               NOTIFY statusChanged)

    Q_PROPERTY(bool hardwareDecoding
               READ hardwareDecoding
               WRITE setHardwareDecoding
               NOTIFY hardwareDecodingChanged)

    Q_PROPERTY(QString mediaTitle
               READ mediaTitle
               NOTIFY mediaTitleChanged)

    Q_PROPERTY(double position
               READ position
               WRITE setPosition
               NOTIFY positionChanged)

    Q_PROPERTY(double duration
               READ duration
               NOTIFY durationChanged)

    Q_PROPERTY(double remaining
               READ remaining
               NOTIFY remainingChanged)

    Q_PROPERTY(int volume
               READ volume
               WRITE setVolume
               NOTIFY volumeChanged)

    Q_PROPERTY(int chapter
               READ chapter
               WRITE setChapter
               NOTIFY chapterChanged)

    Q_PROPERTY(int audioId
               READ audioId
               WRITE setAudioId
               NOTIFY audioIdChanged)

    Q_PROPERTY(int subtitleId
               READ subtitleId
               WRITE setSubtitleId
               NOTIFY subtitleIdChanged)

    Q_PROPERTY(int secondarySubtitleId
               READ secondarySubtitleId
               WRITE setSecondarySubtitleId
               NOTIFY secondarySubtitleIdChanged)

    Q_PROPERTY(int contrast
               READ contrast
               WRITE setContrast
               NOTIFY contrastChanged)

    Q_PROPERTY(int brightness
               READ brightness
               WRITE setBrightness
               NOTIFY brightnessChanged)

    Q_PROPERTY(int gamma
               READ gamma
               WRITE setGamma
               NOTIFY gammaChanged)

    Q_PROPERTY(int saturation
               READ saturation
               WRITE setSaturation
               NOTIFY saturationChanged)

    Q_PROPERTY(double watchPercentage
               MEMBER m_watchPercentage
               READ watchPercentage
               WRITE setWatchPercentage
               NOTIFY watchPercentageChanged)

    Q_PROPERTY(bool hwDecoding
               READ hwDecoding
               WRITE setHWDecoding
               NOTIFY hwDecodingChanged)

//    Q_PROPERTY(PlayListModel* playlistModel
//               READ playlistModel
//               WRITE setPlaylistModel
//               NOTIFY playlistModelChanged)

//    PlayListModel *playlistModel();
//    void setPlaylistModel(PlayListModel *model);

    QString mediaTitle();

    double position();
    void setPosition(double value);

    double remaining();
    double duration();

    int volume();
    void setVolume(int value);

    int chapter();
    void setChapter(int value);

    int audioId();
    void setAudioId(int value);

    int subtitleId();
    void setSubtitleId(int value);

    int secondarySubtitleId();
    void setSecondarySubtitleId(int value);

    int contrast();
    void setContrast(int value);

    int brightness();
    void setBrightness(int value);

    int gamma();
    void setGamma(int value);

    int saturation();
    void setSaturation(int value);

    double watchPercentage();
    void setWatchPercentage(double value);

    bool hwDecoding();
    void setHWDecoding(bool value);

    mpv_handle *mpv;
    mpv_render_context *mpv_gl;

    friend class MpvRenderer;

public:
    MpvObject(QQuickItem * parent = 0);
    virtual ~MpvObject();
    virtual Renderer *createRenderer() const override;

    Q_INVOKABLE QVariant getProperty(const QString &name);
    Q_INVOKABLE QVariant command(const QVariant &params);

    QUrl source() const;

    bool autoPlay() const;

    QMediaPlayer::State getPlaybackState() const;

    QMediaPlayer::MediaStatus getStatus() const;

    bool hardwareDecoding() const;

public slots:
    static void mpvEvents(void *ctx);
    void eventHandler();
    int setProperty(const QString &name, const QVariant &value);

    void setSource(QUrl url);

    void setAutoPlay(bool autoPlay);

    void play();
    void stop();
    void pause();

    void seek(const double &value);

    void setHardwareDecoding(bool hardwareDecoding);

signals:
    void mediaTitleChanged();
    void positionChanged();
    void durationChanged();
    void remainingChanged();
    void volumeChanged();

    void paused();
    void playing();
    void stopped();
    void error(QString error);

    void chapterChanged();
    void audioIdChanged();
    void subtitleIdChanged();
    void secondarySubtitleIdChanged();
    void contrastChanged();
    void brightnessChanged();
    void gammaChanged();
    void saturationChanged();
    void fileLoaded();
    void endOfFile();
    void watchPercentageChanged();
    void ready();
    void audioTracksModelChanged();
    void subtitleTracksModelChanged();
    void hwDecodingChanged();
//    void playlistModelChanged();
//    void youtubePlaylistLoaded();

    void sourceChanged(QUrl url);

    void autoPlayChanged(bool autoPlay);
    
    void playbackStateChanged(QMediaPlayer::State playbackState);

    void statusChanged(QMediaPlayer::MediaStatus  status);

    void hardwareDecodingChanged(bool hardwareDecoding);

private:
    TracksModel *audioTracksModel() const;
    TracksModel *subtitleTracksModel() const;
    TracksModel *m_audioTracksModel;
    TracksModel *m_subtitleTracksModel;
    QMap<int, Track*> m_subtitleTracks;
    QMap<int, Track*> m_audioTracks;
    QList<int> m_secondsWatched;
    double m_watchPercentage;
//    PlayListModel *m_playlistModel;
    QString m_file;

    void loadTracks();
    void playUrl();
    void setPlaybackState(const QMediaPlayer::State &state);
    void setStatus(const QMediaPlayer::MediaStatus  &status);

    QUrl m_source;
    bool m_autoPlay;
    QMediaPlayer::State m_playbackState;
    QMediaPlayer::MediaStatus  m_status = QMediaPlayer::NoMedia;
    bool m_hardwareDecoding = true;
};

class MpvRenderer : public QQuickFramebufferObject::Renderer
{
public:
    MpvRenderer(MpvObject *new_obj);
    ~MpvRenderer() = default;

    MpvObject *obj;

    // This function is called when a new FBO is needed.
    // This happens on the initial frame.
    QOpenGLFramebufferObject * createFramebufferObject(const QSize &size) override final;

    void render() override final;
};

#endif // MPVOBJECT_H
