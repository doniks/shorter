#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQuick>

#include "CachingNetworkManagerFactory.h"
#include "xml2json/utilities.h"
#include "networkmanager.h"

#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("doniks.shorter");

    //qSetMessagePattern("%{file}- %{line}: %{function} M: %{message}");

    QQuickView view;

    CachingNetworkManagerFactory *managerFactory = new CachingNetworkManagerFactory();
    view.engine()->setNetworkAccessManagerFactory(managerFactory);

    view.engine()->rootContext()->setContextProperty("utilities",  new Utilities());
    view.engine()->rootContext()->setContextProperty("networkManager", new NetworkManager());

    view.setSource(QUrl(QStringLiteral("qrc:///qml/shorts-app.qml")));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.show();
    return app.exec();
}

