#include "qcheapruler.hpp"
#include "naviapi_adaptor.h"

#include <QString>

QCheapRuler::QCheapRuler()
{
    //set the default current position
    // m_currentPosition = QGeoCoordinate(36.136261, -115.151254);
    m_currentPosition = QGeoCoordinate(35.692396, 139.691102);
}

QCheapRuler::~QCheapRuler()
{
}

//get route distance
double QCheapRuler::distance() const
{
    return m_distance;
}

//get current distance along the route
double QCheapRuler::currentDistance() const
{
    return m_currentDistance;
}

//set current position below the coordinate info from navigation service
void QCheapRuler::setCurrentPosition(double latitude, double longitude)
{
    //set coordinate info and notify the changes when latitude or longitude info has changed
    if((m_currentPosition.latitude() != latitude)
     ||(m_currentPosition.longitude() != longitude))
    {
        m_currentPosition.setLatitude(latitude);
        m_currentPosition.setLongitude(longitude);
        emit currentPositionChanged();
    }
}

void QCheapRuler::setCurrentDistance(double distance)
{
    //set current distance info and notify the changes when the info has changed
    //but it will not send notify when it start or stop demo
    if((m_currentDistance != distance)
    &&(distance != 0.0))
    {
        m_currentDistance = distance;
        emit currentDistanceChanged();
    }
}

//get current position(coordinate)
QGeoCoordinate QCheapRuler::currentPosition() const
{
    return m_currentPosition;
}

QJSValue QCheapRuler::path() const
{
    // Should neveer be called.
    return QJSValue();
}

//set route path and get the total distance
void QCheapRuler::setPath(const QJSValue &value)
{
    if (!value.isArray())
        return;

    m_path.clear();
    quint32 length = value.property(QStringLiteral("length")).toUInt();

    //push back the coordinate info along the route
    for (unsigned i = 0; i < length; ++i) {
        auto property = value.property(i);
        cr::point coordinate = { 0., 0. };

        if (property.hasProperty(QStringLiteral("latitude")))
            coordinate.y = property.property(QStringLiteral("latitude")).toNumber();

        if (property.hasProperty(QStringLiteral("longitude")))
            coordinate.x = property.property(QStringLiteral("longitude")).toNumber();

        m_path.push_back(coordinate);
    }

    //count the total distance along the route
    double distance = ruler().lineDistance(m_path);
    if (m_distance != distance) {
        m_distance = distance;
    }

    emit pathChanged();
}

//init the route and postion info when start in the first time.(can be called by qml)
void QCheapRuler::initRouteInfo()
{
    //send "getRouteInfo" message to the navigation service
    QDBusMessage message = QDBusMessage::createSignal("/", "org.agl.naviapi", "getRouteInfo");
    if(!QDBusConnection::sessionBus().send(message))
    {
       qDebug() << "initRouteInfo" << "sessionBus.send(): getRouteInfo failed";
    }
}

//init the CheapRuler class
cr::CheapRuler QCheapRuler::ruler() const
{
    if (m_path.empty()) {
        return cr::CheapRuler(0., cr::CheapRuler::Kilometers);
    } else {
        return cr::CheapRuler(m_currentPosition.latitude(), cr::CheapRuler::Kilometers);
    }
}
