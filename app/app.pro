TARGET = navigation
QT = quick qml aglextras
PKGCONFIG += qlibhomescreen qlibwindowmanager

equals(DEFINES, "DESKTOP"){
    QT -= aglextras
    PKGCONFIG -= qlibhomescreen qlibwindowmanager
}

QT += positioning
QT += core
CONFIG += c++11 link_pkgconfig

HEADERS += \
    markermodel.h \
    guidance_module.h \
    file_operation.h

SOURCES += main.cpp \
    file_operation.cpp

RESOURCES += \
    navigation.qrc \
    images/images.qrc

include(app.pri)

DISTFILES +=


