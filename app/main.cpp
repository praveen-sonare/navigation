#include <QQmlApplicationEngine>

#include <QtCore/QDebug>
#include <QtCore/QCommandLineParser>
#include <QtCore/QUrlQuery>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickWindow>

#include "qcheapruler.hpp"

#ifdef HAVE_LIBHOMESCREEN
#include <libhomescreen.hpp>
#endif
#ifdef HAVE_QLIBWINDOWMANAGER
#include <qlibwindowmanager.h>
#endif

int main(int argc, char *argv[])
{
    QString myname = QString("tbtnavi");

    QGuiApplication app(argc, argv);
    app.setApplicationName(myname);
    app.setApplicationVersion(QStringLiteral("0.1.0"));
    app.setOrganizationDomain(QStringLiteral("automotivelinux.org"));
    app.setOrganizationName(QStringLiteral("AutomotiveGradeLinux"));

    QCommandLineParser parser;
    parser.addPositionalArgument("port", app.translate("main", "port for binding"));
    parser.addPositionalArgument("secret", app.translate("main", "secret for binding"));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.process(app);
    QStringList positionalArguments = parser.positionalArguments();

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();
    QUrl bindingAddress;
    int port = 0;
    QString secret;
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

#ifdef HAVE_QLIBWINDOWMANAGER
    // WindowManager
    QLibWindowmanager* qwm = new QLibWindowmanager();
    if(qwm->init(port,secret) != 0){
        exit(EXIT_FAILURE);
    }
    // Request a surface as described in layers.json windowmanager’s file
    if(qwm->requestSurface(myname) != 0){
        exit(EXIT_FAILURE);
    }
#endif

#ifdef HAVE_LIBHOMESCREEN
    // HomeScreen
    LibHomeScreen* hs = new LibHomeScreen();
    std::string token = secret.toStdString();
    hs->init(port, token.c_str());
    // Set the event handler for Event_TapShortcut which will activate the surface for windowmanager
    hs->set_event_handler(LibHomeScreen::Event_TapShortcut, [qwm, myname](json_object *object){

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
//                qwm->activateWindow(myname, QString(QLatin1String(displayArea)));
                qwm->activateWindow(myname, "master.split.sub");
            }
        }
    });
#endif
    qmlRegisterType<QCheapRuler>("com.mapbox.cheap_ruler", 1, 0, "CheapRuler");

    engine.load(QUrl(QStringLiteral("qrc:qml/Main.qml")));

    QObject *root = engine.rootObjects().first();
    QQuickWindow *window = qobject_cast<QQuickWindow *>(root);
#ifdef HAVE_QLIBWINDOWMANAGER
//    QObject::connect(window, SIGNAL(frameSwapped()), qwm, SLOT(slotActivateSurface()));
    // Create an event callback against an event type. Here a lambda is called when SyncDraw event occurs
    qwm->set_event_handler(QLibWindowmanager::Event_SyncDraw, [root, qwm, myname](json_object *object) {
        fprintf(stderr, "Surface got syncDraw!\n");
        qwm->endDraw(myname);
        QMetaObject::invokeMethod(root, "startDemo", Q_ARG(QVariant, true));
    });
    // Create an event callback against an event type. Here a lambda is called when SyncDraw event occurs
    qwm->set_event_handler(QLibWindowmanager::Event_Active, [root](json_object *object) {
        fprintf(stderr, "Surface got Event_Active!\n");
    });
#else
    window->resize(1024, 768);
    window->setVisible(true);
#endif

    return app.exec();
}
