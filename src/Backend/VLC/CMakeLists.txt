project( "vlmc" )

include_directories(LibVLCpp)
add_definitions(-DQT_SHARED)
list(APPEND BACKEND_VLC_SRCS
    EventWaiter.cpp
    VLCBackend.cpp
    VLCSourceRenderer.cpp
    VLCVmemRenderer.cpp
    VLCSource.cpp
    VLCMemorySource.cpp
        LibVLCpp/VLCInstance.cpp
        LibVLCpp/VLCMedia.cpp
        LibVLCpp/VLCMediaPlayer.cpp
        LibVLCpp/VLCpp.hpp
    )

add_library(backend_vlc SHARED ${BACKEND_VLC_SRCS} )
qt_use_modules(backend_vlc Core Gui)
