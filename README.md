# navigation

#reference

https://doc-snapshots.qt.io/qt5-5.9/qtlocation-mapviewer-example.html

#build step

source /SDK_PATH/environment-setup-aarch64-agl-linux

mkdir build

cd build

qmake ../

make

#configuration

Please set mapAccessToken, mapStyleUrl, speed,
interval, latitude and longitude in JSON format
in /etc/naviconfig.ini

mapAccessToken sets Access token provided by Mapbox.
speed sets vehicle speed in km / h.
interval sets the screen update interval in milliseconds.
latitude, longitute sets the current position at application start.
mapStyleUrls sets Mapbox style URLs.

example
{
	"mapAccessToken":"pk.***********",
	"speed":60,
	"interval":100,
	"latitude":36.1363,
	"longitute":-115.151,
	"mapStyleUrls":"mapbox://styles/mapbox/dark-v9"
}

#Qt Creator
If you want to start from Qt Creater
add 'DEFINES * = DESKTOP' to project > build step > additional argument

