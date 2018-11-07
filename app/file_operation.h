#ifndef FILE_OPERATION_H
#define FILE_OPERATION_H
#include <QObject>
#include <QString>
#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>

/******************************************************
 * Write navigation config in /etc/naviconfig.ini
 ******************************************************/
#define NAVI_CONFIG_FILEPATH "/etc/naviconfig.ini"

class File_Operation: public QObject{

    Q_OBJECT

    QString m_mapAccessToken;
    QString m_mapStyle;
    double m_car_speed;         // set Km/h
    int m_update_interval;      // set millisecond
    double m_start_latitude;
    double m_start_longitute;

public:
    File_Operation();
    ~File_Operation();

    Q_INVOKABLE QString getMapAccessToken();
    Q_INVOKABLE QString getMapStyle();
    Q_INVOKABLE double getCarSpeed();
    Q_INVOKABLE int getUpdateInterval();
    Q_INVOKABLE double getStartLatitude();
    Q_INVOKABLE double getStartLongitute();

private:
    void initFileOperation();
};

#endif // FILE_OPERATION_H
