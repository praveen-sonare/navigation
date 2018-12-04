#ifndef FILE_OPERATION_H
#define FILE_OPERATION_H
#include <QObject>
#include <QString>
#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>

/******************************************************
 * Write access token of mapbox in /etc/mapAccessToken
 ******************************************************/
#define MAP_ACCESS_TOKEN_FILEPATH "/etc/naviconfig.ini"

class File_Operation: public QObject{

    Q_OBJECT

    QString m_mapAccessToken;
    double m_car_speed;         // set Km/h
    int m_update_interval;      // set millisecond
    double m_start_latitude;
    double m_start_longitute;

public:
    File_Operation();
    ~File_Operation();

    Q_INVOKABLE QString getMapAccessToken();
    Q_INVOKABLE double getCarSpeed();
    Q_INVOKABLE int getUpdateInterval();
    Q_INVOKABLE double getStartLatitude();
    Q_INVOKABLE double getStartLongitute();

private:
    void initFileOperation();
};

#endif // FILE_OPERATION_H
