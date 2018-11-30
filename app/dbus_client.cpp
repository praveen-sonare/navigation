#include "dbus_client.h"

dbus_client::dbus_client(const QString &pathName,
                         const QString &objName,
                         const QString &serverName,
                         QObject *parent) :
  m_serverName(serverName),
  m_pathName(pathName + serverName),
  m_objName(objName + serverName)
{
    //DBus & api ini
    initDBus();
    initAPIs(parent);
}

dbus_client::~dbus_client(){}

void dbus_client::initDBus(){

    new NaviapiAdaptor(this);

    //make a connect session to navigation service(add route info)
    if (!QDBusConnection::sessionBus().connect(
                QString(),
                QString(),
                m_pathName,
                "signalRouteInfo",
                this,
                SLOT(addRoutePointsSlot(double, double, double, double)))) {	//slot
        qDebug() << m_serverName << "sessionBus.connect(): signalRouteInfo failed";
    }

    //make a connect session to navigation service(current postion info)
    if (!QDBusConnection::sessionBus().connect(
                QString(),
                QString(),
                m_pathName,
                "signalPosInfo",
                this,
                SLOT(positionSlot(double, double, double, double)))) {	//slot
        qDebug() << m_serverName << "sessionBus.connect(): signalPosInfo failed";
    }

    //make a connect session to navigation service(when demo stopped)
    if (!QDBusConnection::sessionBus().connect(
                QString(),
                QString(),
                m_pathName,
                "signalStopDemo",
                this,
                SLOT(stopdemoSlot()))) {	//slot
        qDebug() << m_serverName << "sessionBus.connect(): signalStopDemo failed";
    }

    //make a connect session to navigation service(when arrived destination)
    if (!QDBusConnection::sessionBus().connect(
                QString(),
                QString(),
                m_pathName,
                "signalArrvied",
                this,
                SLOT(arrivedestSlot()))) {	//slot
        qDebug() << m_serverName << "sessionBus.connect(): signalArrvied failed";
    }
}

void dbus_client::initAPIs(QObject *parent){
    //connect the signal to qml inside function(addRoutePointsQml -> do_addRoutePoint)
    if(!QObject::connect(this, SIGNAL(addRoutePointsQml(QVariant, QVariant, QVariant, QVariant)),
                         parent, SLOT(do_addRoutePoint(QVariant, QVariant, QVariant, QVariant)))) {
        qDebug() << m_serverName << "SIGNAL:addRoutePointsQml to qmlSLOT:do_addRoutePoint connect is failed";
    }

    //connect the signal to qml inside function(positionQml -> do_setCoordinate)
    if(!QObject::connect(this, SIGNAL(positionQml(QVariant, QVariant,QVariant, QVariant)),
                         parent, SLOT(do_setCoordinate(QVariant, QVariant,QVariant, QVariant)))) {
        qDebug() << m_serverName << "SIGNAL:positionQml to qmlSLOT:do_setCoordinate connect is failed";
    }

    //connect the signal to qml inside function(stopdemoQml -> do_stopnavidemo)
    if(!QObject::connect(this, SIGNAL(stopdemoQml()),
                         parent, SLOT(do_stopnavidemo()))) {
        qDebug() << m_serverName << "SIGNAL:stopdemoQml to qmlSLOT:do_stopnavidemo connect is failed";
    }

    //connect the signal to qml inside function(arrivedestQml -> do_arrivedest)
    if(!QObject::connect(this, SIGNAL(arrivedestQml()),
                         parent, SLOT(do_arrivedest()))) {
        qDebug() << m_serverName << "SIGNAL:arrivedestQml to qmlSLOT:do_arrivedest connect is failed";
    }
}

//Signal&&Method
//addRoutePointsSlot -> addRoutePointsQml(use for qml)
void dbus_client::addRoutePointsSlot(double route_Lat_s, double route_Lon_s, double route_Lat_e, double route_Lon_e)
{
    emit addRoutePointsQml(route_Lat_s, route_Lon_s, route_Lat_e, route_Lon_e);
}

//positionSlot -> positionQml(use for qml)
void dbus_client::positionSlot(double cur_Lat_p, double cur_Lon_p,double cur_direction, double cur_distance)
{
    emit positionQml(cur_Lat_p, cur_Lon_p,cur_direction,cur_distance);
}

//stopdemoSlot -> stopdemoQml(use for qml)
void dbus_client::stopdemoSlot()
{
    emit stopdemoQml();
}

//arrivedestSlot -> arrivedestQml(use for qml)
void dbus_client::arrivedestSlot()
{
    emit arrivedestQml();
}
