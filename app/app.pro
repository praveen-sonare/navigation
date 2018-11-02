TARGET = tbtnavi
TEMPLATE = app

QT += qml network quick positioning location sql widgets

CONFIG += c++14

include(app.pri)

ios|android {
    QT -= widgets
}

SOURCES += \
    main.cpp \
    qcheapruler.cpp

HEADERS += \
    qcheapruler.hpp

INCLUDEPATH += \
    ../include

OTHER_FILES += \
    qmapboxlgapp.qml

RESOURCES += \
    images/images.qrc \
    app.qrc

