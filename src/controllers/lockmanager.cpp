/*
    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "lockmanager.h"

#include <QDebug>

#if defined(Q_OS_ANDROID)
#include "android/androidlockbackend.h"
#elif defined(Q_OS_LINUX)
#include "linux/solidlockbackend.h"
#endif

LockManager::LockManager(QObject *parent)
    : QObject(parent)
    , m_inhibit()
{
#if defined(Q_OS_ANDROID)
    m_backend = new AndroidLockBackend(this);
#elif defined(Q_OS_LINUX)
    m_backend = new SolidLockBackend(this);
#endif
}

LockManager::~LockManager() = default;

void LockManager::toggleInhibitScreenLock(const QString &explanation)
{
    if (!m_backend)
        return;

    if (m_inhibit) {
        m_backend->setInhibitionOff();
    } else {
        m_backend->setInhibitionOn(explanation);
    }
    m_inhibit = !m_inhibit;
}

void LockManager::setInhibitionOff()
{
    if (!m_backend)
        return;
qDebug() << "Set Inhibition OOFF";
    m_backend->setInhibitionOff();

    m_inhibit = false;
}

void LockManager::setInhibitionOn(const QString &explanation)
{
    if (!m_backend)
        return;
    qDebug() << "Set Inhibition ON";

    m_backend->setInhibitionOn(explanation);

    m_inhibit = true;
}
