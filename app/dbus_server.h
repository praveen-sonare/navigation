#ifndef DBUS_SERVER_H
#define DBUS_SERVER_H
#include "naviapi_interface.h"
#include "naviapi_adaptor.h"
#include <QtQml/QQmlApplicationEngine>

class DBus_Server : public QObject{

    Q_OBJECT

    QString m_serverName;
    QString m_pathName;
    QString m_objName;

public:
    DBus_Server(const QString &pathName,
                const QString &objName,
                const QString &serverName,
                QObject *parent = nullptr);
    ~DBus_Server();

private:
    void initDBus();
    void initAPIs(QObject*);

signals:
    void doAddPOI(QVariant,QVariant,QVariant);
    void doRemovePOIs(QVariant);
    void doGetRouteInfo();

public slots:
    void addPOI(uint category_id, double poi_Lat, double poi_Lon);
    void removePOIs(uint category_id);
    void getRouteInfoSlot();
    void sendSignalRouteInfo(double srt_lat,double srt_lon,double end_lat,double end_lon);
    void sendSignalPosInfo(double lat,double lon,double drc,double dst);
    void sendSignalStopDemo();
    void sendSignalArrvied();
};
#endif // DBUS_SERVER_H
