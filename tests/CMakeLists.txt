project("vlmc")

include(ExternalProject)

# Fetch gtest
ExternalProject_Add(
    gtest
    SVN_REPOSITORY http://googletest.googlecode.com/svn/trunk/
    TIMEOUT 10
    # Disable install step
    INSTALL_COMMAND ""
    # Wrap download, configure and build steps in a script to log output
    LOG_DOWNLOAD ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
)

# Add its includes to our path
ExternalProject_Get_Property(gtest source_dir)
include_directories(${source_dir}/include)

# Fetch our VLC backend module
get_property(BACKEND_INCLUDE_DIR GLOBAL PROPERTY BACKEND_INCLUDE_DIR)
# And add it to our include path
include_directories(${BACKEND_INCLUDE_DIR})

set(VLMC_TEST_SRCS
    vlmc-test.cpp
    VLCBackendTest.cpp )

add_executable(vlmc-test ${VLMC_TEST_SRCS})
add_dependencies(vlmc-test gtest)

# Add our backend & vlc to the link dependencies
target_link_libraries(vlmc-test backend_vlc)
target_link_libraries(vlmc-test ${LIBVLC_LIBRARY} ${LIBVLCCORE_LIBRARY})

# Also link with gtest:
# fetch the directory which contains the built libraries (gtest & gtest_main)
ExternalProject_Get_Property(gtest binary_dir)
message(STATUS ${binary_dir})
find_library(GTEST_LIBRARIES NAMES gtest gtest_main
    # Give cmake the path we just build gtest into
    PATHS ${binary_dir}
    # and don't bother trying to find gtest on the system
    NO_DEFAULT_PATH
)

target_link_libraries(vlmc-test ${GTEST_LIBRARIES})
# Also add pthread, as gtest requires it
if(UNIX)
    target_link_libraries(vlmc-test "pthread")
endif()

# We also need Qt for some basic stuff
qt_use_modules(vlmc-test Core)

