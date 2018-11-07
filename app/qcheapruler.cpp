#include "qcheapruler.hpp"

#include <QString>

QCheapRuler::QCheapRuler()
{
    readCoordinateFromFile();
    m_Timer = new QTimer(this);
}

QCheapRuler::~QCheapRuler()
{
    m_Timer->stop();
    m_routpoint.clear();
}

double QCheapRuler::distance() const
{
    return m_distance;
}

double QCheapRuler::currentDistance() const
{
    return m_currentDistance;
}

void QCheapRuler::setCurrentCoordinate(QString m_latitude,QString m_longitude)
{
	double latitude = m_latitude.toDouble();
	double longitude = m_longitude.toDouble();
	setCurrentPosition(latitude,longitude);
}

void QCheapRuler::setCurrentPosition(double latitude,double longitude)
{
    if((latitude == 0.0)&&(longitude == 0.0))
    {
        emit arrivedDest();
    }
    else
    {
        if((m_currentPosition.latitude() != latitude)
         ||(m_currentPosition.longitude() != longitude))
        {
            cr::point pre_postion = cr::point(m_currentPosition.longitude(),m_currentPosition.latitude());
            cr::point current_postion = cr::point(longitude,latitude);
            m_currentDistance += ruler().distance(pre_postion,current_postion);
            emit currentDistanceChanged();

            m_currentPosition.setLatitude(latitude);
            m_currentPosition.setLongitude(longitude);
            emit currentPositionChanged();
        }
    }
}

void QCheapRuler::readRoutePosition()
{
    m_index ++;
    if(m_index < m_routpoint.size())
    {
        qDebug("m_index:%d lan:%f  lon:%f!\n",m_index,m_routpoint.at(m_index).y,m_routpoint.at(m_index).x);
        setCurrentPosition(m_routpoint.at(m_index).y,m_routpoint.at(m_index).x);
    }
    else
    {
        m_Timer->stop();
    }
}

QGeoCoordinate QCheapRuler::currentPosition() const
{
    return m_currentPosition;
}

QJSValue QCheapRuler::path() const
{
    // Should neveer be called.
    return QJSValue();
}

void QCheapRuler::startnaviDemo()
{
    if (m_routpoint.empty()) {
        return;
    }

    m_currentDistance = 0.;
    m_index = 0;
    connect(m_Timer, SIGNAL(timeout()), this, SLOT(readRoutePosition()));
    m_Timer->start(100);
}

void QCheapRuler::stopnaviDemo()
{
    m_currentDistance = 0.;
    m_index = 0;
    m_Timer->stop();
}

void QCheapRuler::setPath(const QJSValue &value)
{
    if (!value.isArray())
        return;

    m_path.clear();
    quint32 length = value.property(QStringLiteral("length")).toUInt();

    for (unsigned i = 0; i < length; ++i) {
        auto property = value.property(i);
        cr::point coordinate = { 0., 0. };

        if (property.hasProperty(QStringLiteral("latitude")))
            coordinate.y = property.property(QStringLiteral("latitude")).toNumber();

        if (property.hasProperty(QStringLiteral("longitude")))
            coordinate.x = property.property(QStringLiteral("longitude")).toNumber();

        m_path.push_back(coordinate);
    }

    double distance = ruler().lineDistance(m_path);
    if (m_distance != distance) {
        m_distance = distance;
    }

    emit pathChanged();
}

cr::CheapRuler QCheapRuler::ruler() const
{
    if (m_path.empty()) {
        return cr::CheapRuler(0., cr::CheapRuler::Kilometers);
    } else {
        return cr::CheapRuler(m_currentPosition.latitude(), cr::CheapRuler::Kilometers);
    }
}

void QCheapRuler::readCoordinateFromFile()
{
    m_routpoint.clear();

    QFile *file = new QFile("/var/local/lib/afm/applications/tbtnavi/0.1/Coordinate.txt");
    if(!file->exists())
    {
        file = new QFile(":/qml/Coordinate.txt");
        if(!file->exists())
        {
            qDebug("Coordinate File not exit!\n");
            return;
        }
    }

    if(!file->open(QIODevice::ReadOnly | QIODevice::Text))
    {
      qDebug("Can not open Coordinate File!\n");
      return;
    }

    QTextStream m_StreamIn(file);
    while (!m_StreamIn.atEnd()) {
        QString line = m_StreamIn.readLine();

        QStringList sections = line.split(QRegExp(","));
        cr::point temp = cr::point(sections.at(1).trimmed().toDouble(),sections.at(0).trimmed().toDouble());
        m_routpoint.push_back(temp);
    }

    file->close();
}
