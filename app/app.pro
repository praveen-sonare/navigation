TARGET = tbtnavi
TEMPLATE = app

QT += qml network quick positioning location sql widgets dbus

CONFIG += c++14

include(app.pri)

ios|android {
    QT -= widgets
}

SOURCES += \
    main.cpp \
    qcheapruler.cpp \
    dbus_client.cpp

HEADERS += \
    qcheapruler.hpp \
    dbus_client.h

INCLUDEPATH += \
    ../include

OTHER_FILES += \
    qmapboxlgapp.qml

RESOURCES += \
    images/images.qrc \
    app.qrc

DBUS_ADAPTORS += org.agl.naviapi.xml
DBUS_INTERFACES += org.agl.naviapi.xml
