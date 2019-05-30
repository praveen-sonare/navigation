#ifndef FILE_OPERATION_H
#define FILE_OPERATION_H
#include <QObject>
#include <QString>
#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>

/******************************************************
 * Please set mapAccessToken, mapStyleUrl, speed,
 * interval, latitude and longitude in JSON format
 * in /etc/naviconfig.ini
 ******************************************************/
#define NAVI_CONFIG_FILEPATH "/etc/naviconfig.ini"

class File_Operation: public QObject{

    Q_OBJECT

    QString m_mapAccessToken;
    double m_car_speed;         // set Km/h
    int m_update_interval;      // set millisecond
    double m_start_latitude;
    double m_start_longitute;
    QString m_mapStyleUrls;

public:
    File_Operation();
    ~File_Operation();

    Q_INVOKABLE QString getMapAccessToken();
    Q_INVOKABLE double getCarSpeed();
    Q_INVOKABLE int getUpdateInterval();
    Q_INVOKABLE double getStartLatitude();
    Q_INVOKABLE double getStartLongitute();
    Q_INVOKABLE QString getMapStyleUrls();

private:
    void initFileOperation();
};

#endif // FILE_OPERATION_H
