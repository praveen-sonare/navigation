#pragma once

#include <QGeoCoordinate>
#include <QJSValue>
#include <QObject>
#include <QtCore>

#include <mapbox/cheap_ruler.hpp>

namespace cr = mapbox::cheap_ruler;

class QCheapRuler : public QObject{
    Q_OBJECT
    Q_PROPERTY(double distance READ distance NOTIFY distanceChanged)
    Q_PROPERTY(double currentDistance READ currentDistance NOTIFY currentDistanceChanged)
    Q_PROPERTY(QGeoCoordinate currentPosition READ currentPosition  NOTIFY currentPositionChanged)
    Q_PROPERTY(QJSValue path READ path WRITE setPath NOTIFY pathChanged)

public:
    QCheapRuler();
     ~QCheapRuler();

    double distance() const;

    double currentDistance() const;

    QGeoCoordinate currentPosition() const;

    QJSValue path() const;
    void setPath(const QJSValue &value);

    Q_INVOKABLE void setCurrentCoordinate(QString,QString);
    Q_INVOKABLE void startnaviDemo();
    Q_INVOKABLE void stopnaviDemo();

public slots:
    void readRoutePosition();

signals:
    void distanceChanged();
    void currentDistanceChanged();
    void currentPositionChanged();
    void pathChanged();
    void arrivedDest();

private:
    cr::CheapRuler ruler() const;
    void readCoordinateFromFile();
	void setCurrentPosition(double,double);

    ulong m_index = 0;
    double m_distance = 0.;
    double m_currentDistance = 0.;
    QGeoCoordinate m_currentPosition = QGeoCoordinate(36.12546, -115.1729906);

    cr::line_string m_path;

    cr::line_string m_routpoint;

    QTimer *m_Timer;
};
