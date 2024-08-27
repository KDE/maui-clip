/*
    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "androidlockbackend.h"

#include <QDebug>
#include <QJniEnvironment>
#include <QJniObject>

AndroidLockBackend::AndroidLockBackend(QObject *parent)
    : LockBackend(parent)
{
}

AndroidLockBackend::~AndroidLockBackend()
{
}

void AndroidLockBackend::setInhibitionOff()
{
    QJniObject activity = QJniObject::callStaticObjectMethod("org/qtproject/qt/android/QtNative", "activity", "()Landroid/app/Activity;"); // activity is valid

    QJniObject::callStaticMethod<void>("org.maui.clip.Solid", "setLockInhibitionOff", "(Landroid/app/Activity;)V", activity.object<jobject>());
}

void AndroidLockBackend::setInhibitionOn(const QString &explanation)
{
    Q_UNUSED(explanation)
    QJniObject activity = QJniObject::callStaticObjectMethod("org/qtproject/qt/android/QtNative", "activity", "()Landroid/app/Activity;"); // activity is valid

    QJniObject::callStaticMethod<void>("org.maui.clip.Solid", "setLockInhibitionOn", "(Landroid/app/Activity;)V", activity.object<jobject>());
}
