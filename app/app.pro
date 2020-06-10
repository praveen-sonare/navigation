TARGET = navigation

CONFIG += link_pkgconfig
PKGCONFIG += libhomescreen qlibwindowmanager

QT = qml network quick positioning location quickcontrols2

static {
    QTPLUGIN += qtvirtualkeyboardplugin
    QT += svg
}

CONFIG(release, debug|release) {
    QMAKE_POST_LINK = $(STRIP) --strip-unneeded $(TARGET)
}

SOURCES += main.cpp

RESOURCES += \
    mapviewer.qrc

OTHER_FILES +=mapviewer.qml \
    helper.js \
    map/MapComponent.qml \
    map/Marker.qml \
    map/CircleItem.qml \
    map/RectangleItem.qml \
    map/PolylineItem.qml \
    map/PolygonItem.qml \
    map/ImageItem.qml \
    menus/ItemPopupMenu.qml \
    menus/MainMenu.qml \
    menus/MapPopupMenu.qml \
    menus/MarkerPopupMenu \
    forms/Geocode.qml \
    forms/GeocodeForm.ui.qml\
    forms/Message.qml \
    forms/MessageForm.ui.qml \
    forms/ReverseGeocode.qml \
    forms/ReverseGeocodeForm.ui.qml \
    forms/RouteCoordinate.qml \
    forms/Locale.qml \
    forms/LocaleForm.ui.qml \
    forms/RouteAddress.qml \
    forms/RouteAddressForm.ui.qml \
    forms/RouteCoordinateForm.ui.qml \
    forms/RouteList.qml \
    forms/RouteListDelegate.qml \
    forms/RouteListHeader.qml

include(app.pri)
