TARGET = navigation
QT = quick qml

QT += aglextras
PKGCONFIG += qlibhomescreen qlibwindowmanager

QT += positioning
QT += dbus
QT += core
CONFIG += c++11 link_pkgconfig

HEADERS += \
    markermodel.h \
    dbus_server.h \
    guidance_module.h \
    file_operation.h

SOURCES += main.cpp \
    dbus_server.cpp

RESOURCES += \
    navigation.qrc \
    images/images.qrc

DBUS_ADAPTORS += dbusinterface/org.agl.naviapi.xml
DBUS_INTERFACES += dbusinterface/org.agl.naviapi.xml

include(app.pri)

