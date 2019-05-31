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

#ifdef DESKTOP
#define USE_QTAGLEXTRAS			0
#define USE_QLIBWINDOWMANAGER	0
#else
#define USE_QTAGLEXTRAS			0
#define USE_QLIBWINDOWMANAGER	1
#endif

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
#include <QtDBus/QDBusConnection>
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

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();
    QUrl bindingAddress;
    int port = 0;
    QString secret;

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
        secret = positionalArguments.takeFirst();
        bindingAddress.setScheme(QStringLiteral("ws"));
        bindingAddress.setHost(QStringLiteral("localhost"));
        bindingAddress.setPort(port);
        bindingAddress.setPath(QStringLiteral("/api"));
        QUrlQuery query;
        query.addQueryItem(QStringLiteral("token"), secret);
        bindingAddress.setQuery(query);
        context->setContextProperty(QStringLiteral("bindingAddress"), bindingAddress);
    } else {
        context->setContextProperty(QStringLiteral("bindingAddress"), bindingAddress);
    }

    fprintf(stderr, "[navigation]app_name: %s, port: %d, secret: %s.\n",
					myname.toStdString().c_str(),
					port,
                    secret.toStdString().c_str());
	// QLibWM
	QLibWindowmanager* qwmHandler = new QLibWindowmanager();
	int res;
    if((res = qwmHandler->init(port,secret)) != 0){
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
    qhsHandler->init(port, secret.toStdString().c_str());
	qhsHandler->set_event_handler(QLibHomeScreen::Event_TapShortcut, [qwmHandler, myname](json_object *object){
        qDebug("Surface %s got tapShortcut\n", qPrintable(myname));
        qwmHandler->activateWindow(myname);
	});
	// Load qml

    MarkerModel model;
	engine.rootContext()->setContextProperty("markerModel", &model);

    Guidance_Module guidance;
	engine.rootContext()->setContextProperty("guidanceModule", &guidance);

    File_Operation file;
    engine.rootContext()->setContextProperty("fileOperation", &file);

	engine.load(QUrl(QStringLiteral("qrc:/navigation.qml")));
 	QObject *root = engine.rootObjects().first();
	QQuickWindow *window = qobject_cast<QQuickWindow *>(root);
    qhsHandler->setQuickWindow(window);

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
#endif
	
	return app.exec();
}

