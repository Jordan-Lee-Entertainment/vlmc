/*****************************************************************************
 * AudioProjectPreferences.cpp: VLMC Audio project preferences class
 *****************************************************************************
 * Copyright (C) 2008-2010 VideoLAN
 *
 * Authors: Geoffroy Lacarriere <geoffroylaca@gmail.com>
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

#include <QDebug>

#include "AudioProjectPreferences.h"

AudioProjectPreferences::AudioProjectPreferences( QWidget *parent )
    : PreferenceWidget( parent ),
    m_type( SettingsManager::Project )
{
    m_ui.setupUi( this );
}

AudioProjectPreferences::~AudioProjectPreferences() { }

void    AudioProjectPreferences::load()
{
    int sampleRate = VLMC_PROJECT_GET_INT( "audio/AudioSampleRate" );
    m_ui.SampleRate->setValue( sampleRate );
    return ;
}

void    AudioProjectPreferences::save()
{
    SettingsManager* setMan = SettingsManager::getInstance();
    QVariant    sampleRate( m_ui.SampleRate->value() );
    setMan->setImmediateValue( "audio/AudioSampleRate", sampleRate, m_type );
    return ;
}

void AudioProjectPreferences::changeEvent( QEvent *e )
{
    QWidget::changeEvent( e );
    switch ( e->type() )
    {
    case QEvent::LanguageChange:
        m_ui.retranslateUi( this );
        break;
    default:
        break;
    }
}
