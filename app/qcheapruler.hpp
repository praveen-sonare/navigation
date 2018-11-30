#pragma once

#include <QGeoCoordinate>
#include <QJSValue>
#include <QObject>
#include <QtCore>

#include <mapbox/cheap_ruler.hpp>

namespace cr = mapbox::cheap_ruler;

class QCheapRuler : public QObject{
    Q_OBJECT
    //registy the read write&notify function for qml
    //the distance from start point to end point(read only)
    Q_PROPERTY(double distance READ distance)
    //the distance from start point to current postion along the route(read notify)
    Q_PROPERTY(double currentDistance READ currentDistance NOTIFY currentDistanceChanged)
    //the coordinate info of current postion(read)
    Q_PROPERTY(QGeoCoordinate currentPosition READ currentPosition NOTIFY currentPositionChanged)
    //the route path info postion(read write&notify)
    Q_PROPERTY(QJSValue path READ path WRITE setPath NOTIFY pathChanged)

public:
    QCheapRuler();
     ~QCheapRuler();

    //read write&notify function  for qml
    double distance() const;
    double currentDistance() const;
    QGeoCoordinate currentPosition() const;
    QJSValue path() const;
    void setPath(const QJSValue &value);

    //functions that can called by qml(Q_INVOKABLE)
    Q_INVOKABLE void initRouteInfo();
    Q_INVOKABLE void setCurrentPosition(double, double, double);

signals:
    //notify signals to  qml
    //notify signal when the distance from start point to current postion changed
    void currentDistanceChanged();
    //notify signal when currentPosition changed
    void currentPositionChanged();
    //notify signal when the distance from start point to current postion changed
    void pathChanged();

private:
    cr::CheapRuler ruler() const;

    double m_distance = 0.;
    double m_currentDistance = 0.;
    QGeoCoordinate m_currentPosition;

    cr::line_string m_path;
};
