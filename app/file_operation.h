#ifndef FILE_OPERATION_H
#define FILE_OPERATION_H
#include <QObject>
#include <QString>
#include <QFile>
#include <QFile>
#include <QJsonObject>
#include <QJsonDocument>

/******************************************************
 * Write access token of mapbox in /etc/mapAccessToken
 ******************************************************/
#define MAP_ACCESS_TOKEN_FILEPATH "/etc/mapAccessToken"

class File_Operation: public QObject{

    Q_OBJECT
public:
    Q_INVOKABLE QString getMapAccessToken() {
    #if 0
        char buf[512];
        QString mapAccessToken = "";

        FILE* filep = fopen(qPrintable(MAP_ACCESS_TOKEN_FILEPATH), "r");
        if (!filep) {
            fprintf(stderr,"Failed to open mapAccessToken file \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
            return mapAccessToken;
        }
        if (!fgets(buf, 512, filep)) {
            fprintf(stderr,"Failed to read mapAccessToken from mapAccessToken file \"%s\"", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
            fclose(filep);
            return mapAccessToken;
        }
        if (strlen(buf) > 0 && buf[strlen(buf)-1] == '\n') {
            buf[strlen(buf)-1] = '\0';
        }
        mapAccessToken = QString(buf);

        fclose(filep);

        return mapAccessToken;
    #else
    	QString mapAccessToken = "";
    	QFile file(MAP_ACCESS_TOKEN_FILEPATH);
    	if (!file.open(QIODevice::ReadOnly)){
            fprintf(stderr,"Failed to open mapAccessToken file \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
            return mapAccessToken;
        }
        QByteArray data = file.readAll();
        QJsonDocument jsonDoc(QJsonDocument::fromJson(data));
    	QJsonObject jsonObj(jsonDoc.object());
    	if(jsonObj.contains("mapAccessToken")){
    		mapAccessToken = jsonObj["mapAccessToken"].toString();
    	}else{
    		fprintf(stderr,"Failed to find mapAccessToken data \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
    	}
    	
    	file.close();
    	return mapAccessToken;
    #endif
    }
    
    Q_INVOKABLE double getSpeed() {
    	double speed = 60;	// km/h
    	QFile file(MAP_ACCESS_TOKEN_FILEPATH);
    	if (!file.open(QIODevice::ReadOnly)){
            fprintf(stderr,"Failed to open mapAccessToken file \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
            return speed;
        }
        QByteArray data = file.readAll();
        QJsonDocument jsonDoc(QJsonDocument::fromJson(data));
    	QJsonObject jsonObj(jsonDoc.object());
    	if(jsonObj.contains("speed")){
    		speed = jsonObj["speed"].toDouble();
    	}else{
    		fprintf(stderr,"Failed to find speed data \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
    	}
    	
    	file.close();
    	return speed;
    }
    
    Q_INVOKABLE int getInterval() {
    	int interval = 15;	// ms
    	QFile file(MAP_ACCESS_TOKEN_FILEPATH);
    	if (!file.open(QIODevice::ReadOnly)){
            fprintf(stderr,"Failed to open mapAccessToken file \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
            return interval;
        }
        QByteArray data = file.readAll();
        QJsonDocument jsonDoc(QJsonDocument::fromJson(data));
    	QJsonObject jsonObj(jsonDoc.object());
    	if(jsonObj.contains("interval")){
    		interval = (int)jsonObj["interval"].toDouble();
    	}else{
    		fprintf(stderr,"Failed to find interval data \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
    	}
    	
    	file.close();
    	return interval;
    }
    
    Q_INVOKABLE double getLatitude() {
    	double latitude = 36.136261;
    	QFile file(MAP_ACCESS_TOKEN_FILEPATH);
    	if (!file.open(QIODevice::ReadOnly)){
            fprintf(stderr,"Failed to open mapAccessToken file \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
            return latitude;
        }
        QByteArray data = file.readAll();
        QJsonDocument jsonDoc(QJsonDocument::fromJson(data));
    	QJsonObject jsonObj(jsonDoc.object());
    	if(jsonObj.contains("latitude")){
    		latitude = jsonObj["latitude"].toDouble();
    	}else{
    		fprintf(stderr,"Failed to find latitude data \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
    	}
    	
    	file.close();
    	return latitude;
    }
    
     Q_INVOKABLE double getLongitude() {
    	double longitute = -115.151254;
    	QFile file(MAP_ACCESS_TOKEN_FILEPATH);
    	if (!file.open(QIODevice::ReadOnly)){
            fprintf(stderr,"Failed to open mapAccessToken file \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
            return longitute;
        }
        QByteArray data = file.readAll();
        QJsonDocument jsonDoc(QJsonDocument::fromJson(data));
    	QJsonObject jsonObj(jsonDoc.object());
    	if(jsonObj.contains("longitute")){
    		longitute = jsonObj["longitute"].toDouble();
    	}else{
    		fprintf(stderr,"Failed to find longitute data \"%s\": %m", qPrintable(MAP_ACCESS_TOKEN_FILEPATH));
    	}
    	
    	file.close();
    	return longitute;
    }
};

#endif // FILE_OPERATION_H
