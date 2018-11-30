TARGET = navigation
QT = quick qml

QT += aglextras
PKGCONFIG += qlibhomescreen qlibwindowmanager

QT += positioning
QT += core
CONFIG += c++11 link_pkgconfig

HEADERS += \
    markermodel.h \
    guidance_module.h \
    file_operation.h

SOURCES += main.cpp

RESOURCES += \
    navigation.qrc \
    images/images.qrc

include(app.pri)

