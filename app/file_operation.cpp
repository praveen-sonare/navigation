#include "file_operation.h"

File_Operation::File_Operation(){
    initFileOperation();
}

File_Operation::~File_Operation(){

}

void File_Operation::initFileOperation(){

    m_mapAccessToken = "";
    m_car_speed = 60; // set default Km/h
    m_update_interval = 100; // set default millisecond
    m_start_latitude = 36.136261; // set default coordinate Westgate
    m_start_longitute = -115.151254;

    QFile file(MAP_ACCESS_TOKEN_FILEPATH);
    if(!file.open(QIODevice::ReadOnly | QIODevice::Text)){
        fprintf(stderr,"Failed to open mapAccessToken file \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
        return;
    }

    QByteArray data = file.readAll();
    QJsonDocument jsonDoc(QJsonDocument::fromJson(data));
    QJsonObject jsonObj(jsonDoc.object());

    if(jsonObj.contains("mapAccessToken")){
        m_mapAccessToken = jsonObj["mapAccessToken"].toString();
    }else{
        fprintf(stderr,"Failed to find mapAccessToken data \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
        return;
    }

    if(jsonObj.contains("speed")){
        m_car_speed = jsonObj["speed"].toDouble();
    }else{
        fprintf(stderr,"Failed to find speed data \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
        return;
    }

    if(jsonObj.contains("interval")){
        m_update_interval = jsonObj["interval"].toInt();
    }else{
        fprintf(stderr,"Failed to find interval data \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
        return;
    }

    if(jsonObj.contains("latitude")){
        m_start_latitude = jsonObj["latitude"].toDouble();
    }else{
        fprintf(stderr,"Failed to find latitude data \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
        return;
    }

    if(jsonObj.contains("longitute")){
        m_start_longitute = jsonObj["longitute"].toDouble();
    }else{
        fprintf(stderr,"Failed to find longitute data \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
        return;
    }

    file.close();

    return;
}

QString File_Operation::getMapAccessToken() {
    return m_mapAccessToken;
}
double File_Operation::getCarSpeed(){
    return m_car_speed;
}
int File_Operation::getUpdateInterval(){
    return m_update_interval;
}
double File_Operation::getStartLatitude(){
    return m_start_latitude;
}
double File_Operation::getStartLongitute(){
    return m_start_longitute;
}
