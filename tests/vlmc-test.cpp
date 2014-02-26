/*****************************************************************************
 * vlmc-test.cpp: Entry point for VLMC unit tests
 *****************************************************************************
 * Copyright (C) 2008-2014 VideoLAN
 *
 * Authors: Hugo Beauzée-Luyssen <hugo@beauzee.fr>
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

#include <gtest/gtest.h>

#include <QDir>
#include <QString>
#include <QStack>
#include <list>
#include <QProcessEnvironment>

#include "VLCBackendTest.h"

static std::list<std::string> GetSamples()
{
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    QString samplePath = env.value("VLMC_SAMPLES_PATH");
    std::list<std::string>  files;
    if ( samplePath.isEmpty() )
        return files;
    QStack<QString> directories;

    directories.push(samplePath);
    while (directories.isEmpty() == false )
    {
        QString path = directories.pop();
        QDir dir(path);
        foreach (const QFileInfo fInfo, dir.entryInfoList(QDir::Dirs | QDir::Files | QDir::Readable | QDir::NoDotAndDotDot ))
        {
            if ( fInfo.isDir() )
                directories.push( fInfo.absolutePath() );
            else if ( fInfo.isFile() )
            {
                files.push_back( fInfo.absoluteFilePath().toStdString() );
            }
        }
    }
    return files;
}

INSTANTIATE_TEST_CASE_P(SampleBased, VLCBackendTest, ::testing::ValuesIn(GetSamples()));

int main(int argc, char **argv)
{
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
