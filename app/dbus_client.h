#ifndef DBUS_CLIENT_H
#define DBUS_CLIENT_H

#include "naviapi_interface.h"
#include "naviapi_adaptor.h"
#include <QtQml/QQmlApplicationEngine>

class dbus_client : public QObject{
    Q_OBJECT
    QString m_serverName;
    QString m_pathName;
    QString m_objName;

public:
    dbus_client(const QString &pathName,
                const QString &objName,
                const QString &serverName,
                QObject *parent = nullptr);
    ~dbus_client();

private:
    //DBus & API init
    void initDBus();
    void initAPIs(QObject*);

signals:
    //notify add routepoints signal to qml
    void addRoutePointsQml(QVariant, QVariant, QVariant, QVariant);
    //notify current position signal to qml
    void positionQml(QVariant, QVariant,QVariant, QVariant);
    //notify stop demo signal to qml
    void stopdemoQml();
    //notify arrive destination signal to qml
    void arrivedestQml();

private slots:
    //receive add routepoints notify from navigation service
    void addRoutePointsSlot(double route_Lat_s, double route_Lon_s, double route_Lat_e, double route_Lon_e);
    //receive current position notify from navigation service
    void positionSlot(double cur_Lat_p, double cur_Lon_p,double cur_direction, double cur_distance);
    //receive stop demo notify from navigation service
    void stopdemoSlot();
    //receive arrive destination notify from navigation service
    void arrivedestSlot();
};
#endif // DBUS_CLIENT_H
