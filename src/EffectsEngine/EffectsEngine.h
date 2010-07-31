/*****************************************************************************
 * EffectsEngine.h: Manage the effects plugins.
 *****************************************************************************
 * Copyright (C) 2008-2010 VideoLAN
 *
 * Authors: Hugo Beauzée-Luyssen <beauze.h@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/

#ifndef EFFECTSENGINE_H
#define EFFECTSENGINE_H

#include "Singleton.hpp"

class   QTime;

#include "Effect.h"
#include "MainWorkflow.h"

#include <QObject>
#include <QHash>

class   QSettings;

class   EffectsEngine : public QObject, public Singleton<EffectsEngine>
{
    Q_OBJECT

    public:
        struct      EffectHelper
        {
            EffectHelper( EffectInstance* effect, qint64 start = 0, qint64 end = -1,
                          const QString& uuid = QString() );
            EffectInstance*     effect;
            qint64              start;
            qint64              end;
            QUuid               uuid;
        };
        typedef QList<EffectHelper*>    EffectList;

        Effect*     effect( const QString& name );
        bool        loadEffect( const QString& fileName );
        void        browseDirectory( const QString& path );

        static void applyEffects( const EffectList &effects,
                                  Workflow::Frame *frame, qint64 currentFrame, double time );
        static void saveEffects( const EffectList &effects, QXmlStreamWriter &project );
        static void initEffects( const EffectList &effects, quint32 width, quint32 height );

    private:
        EffectsEngine();
        ~EffectsEngine();

        QHash<QString, Effect*> m_effects;
        QSettings               *m_cache;
        QTime                   *m_time;

    signals:
        void        effectAdded( Effect*, const QString& name, Effect::Type );
    friend class    Singleton<EffectsEngine>;
};

#endif // EFFECTSENGINE_H