/*
 * Copyright (C) 2016 The Qt Company Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *	  http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define USE_QTAGLEXTRAS			0
#define USE_QLIBWINDOWMANAGER	1

#if	USE_QTAGLEXTRAS
#include <QtAGLExtras/AGLApplication>
#elif USE_QLIBWINDOWMANAGER
#include <qlibwindowmanager.h>
#include <qlibhomescreen.h>
#include <string>
#endif
#include <QtCore/QDebug>
#include <QtCore/QCommandLineParser>
#include <QtCore/QUrlQuery>
#include <QtCore/QSettings>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQuickControls2/QQuickStyle>
#include <QQuickWindow>
#include "markermodel.h"
#include "guidance_module.h"
#include "file_operation.h"

int main(int argc, char *argv[])
{
#if	USE_QTAGLEXTRAS
	AGLApplication app(argc, argv);
	app.setApplicationName("navigation");
	app.setupApplicationRole("navigation");
 	app.load(QUrl(QStringLiteral("qrc:/navigation.qml")));
	
#elif USE_QLIBWINDOWMANAGER
	QGuiApplication app(argc, argv);
	QString myname = QString("navigation");
	int port = 1700;
	QString token = "hello";
	QCoreApplication::setOrganizationDomain("LinuxFoundation");
	QCoreApplication::setOrganizationName("AutomotiveGradeLinux");
	QCoreApplication::setApplicationName(myname);
	QCoreApplication::setApplicationVersion("0.1.0");
	QCommandLineParser parser;
	parser.addPositionalArgument("port", app.translate("main", "port for binding"));
	parser.addPositionalArgument("secret", app.translate("main", "secret for binding"));
	parser.addHelpOption();
	parser.addVersionOption();
	parser.process(app);
	QStringList positionalArguments = parser.positionalArguments();
	if (positionalArguments.length() == 2) {
		port = positionalArguments.takeFirst().toInt();
		token = positionalArguments.takeFirst();
    }
	fprintf(stderr, "[navigation]app_name: %s, port: %d, token: %s.\n",
					myname.toStdString().c_str(),
					port,
					token.toStdString().c_str());
	// QLibWM
	QLibWindowmanager* qwmHandler = new QLibWindowmanager();
	int res;
	if((res = qwmHandler->init(port,token)) != 0){
		fprintf(stderr, "[navigation]init qlibwm err(%d)\n", res);
		return -1;
	}
	if((res = qwmHandler->requestSurface(myname)) != 0) {
		fprintf(stderr, "[navigation]request surface err(%d)\n", res);
		return -1;
	}
    qwmHandler->set_event_handler(QLibWindowmanager::Event_SyncDraw, [qwmHandler, myname](json_object *object) {
		qwmHandler->endDraw(myname);
	});
    qwmHandler->set_event_handler(QLibWindowmanager::Event_Visible, [qwmHandler, myname](json_object *object) {
        ;
    });
    qwmHandler->set_event_handler(QLibWindowmanager::Event_Invisible, [qwmHandler, myname](json_object *object) {
        ;
    });
	// QLibHS
	QLibHomeScreen* qhsHandler = new QLibHomeScreen();
	qhsHandler->init(port, token.toStdString().c_str());
	qhsHandler->set_event_handler(QLibHomeScreen::Event_TapShortcut, [qwmHandler, myname](json_object *object){
		json_object *appnameJ = nullptr;
		if(json_object_object_get_ex(object, "application_name", &appnameJ))
		{
			const char *appname = json_object_get_string(appnameJ);
			if(QString::compare(myname, appname, Qt::CaseInsensitive) == 0)
			{
				qDebug("Surface %s got tapShortcut\n", appname);
				json_object *para, *area;
				json_object_object_get_ex(object, "parameter", &para);
				json_object_object_get_ex(para, "area", &area);
				const char *displayArea = json_object_get_string(area);
				qDebug("Surface %s got tapShortcut area\n", displayArea);
				qwmHandler->activateWindow(myname, QString(QLatin1String(displayArea)));
			}
		}
	});
	// Load qml
	QQmlApplicationEngine engine;

    MarkerModel model;
	engine.rootContext()->setContextProperty("markerModel", &model);

    Guidance_Module guidance;
	engine.rootContext()->setContextProperty("guidanceModule", &guidance);

    File_Operation file;
    engine.rootContext()->setContextProperty("fileOperation", &file);

	engine.load(QUrl(QStringLiteral("qrc:/navigation.qml")));
 	QObject *root = engine.rootObjects().first();
	QQuickWindow *window = qobject_cast<QQuickWindow *>(root);
	// QObject::connect(window, SIGNAL(frameSwapped()), qwmHandler, SLOT(slotActivateSurface()));
	qhsHandler->setQuickWindow(window);
    QObject *map = engine.rootObjects().first()->findChild<QObject*>("map");

#else	// for only libwindowmanager
	QGuiApplication app(argc, argv);
    app.setApplicationName("navigation");

	// Load qml
	QQmlApplicationEngine engine;

    MarkerModel model;
    engine.rootContext()->setContextProperty("markerModel", &model);

    Guidance_Module guidance;
    engine.rootContext()->setContextProperty("guidanceModule", &guidance);

    File_Operation file;
    engine.rootContext()->setContextProperty("fileOperation", &file);

    engine.load(QUrl(QStringLiteral("qrc:/navigation.qml")));
    QObject *map = engine.rootObjects().first()->findChild<QObject*>("map");

#endif
	
	return app.exec();
}

