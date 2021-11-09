#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <QScreen>
#include <QMainWindow>
#include <QQuickView>


int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain(("qomodoro"));
    QCoreApplication::setOrganizationName(QStringLiteral("qomodoro"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("qomodoro"));
    QCoreApplication::setApplicationName(QStringLiteral("Qomodoro"));

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
    }
    // const auto rootObjects = engine.rootObjects();
    // for (auto obj : rootObjects) {
    //     auto w = qobject_cast<QMainWindow *>(obj);
    //     if (w) {
    //         w->setWindowFlags(Qt::Dialog);
    //         w->show();
    //     }
    // }
    //QWindow *qmlWindow = qobject_cast<QWindow*>(engine.rootObjects().at(0));
    ////QScreen *screen = QGuiApplication::primaryScreen();
    //QWidget *container = QWidget::createWindowContainer(qmlWindow);
    //container->setMinimumSize(qmlWindow->size());
    //QWidget *widget = new QWidget();
    //QGridLayout *grid = new QGridLayout(widget);
    //grid->addWidget(container,0,0);
    //widget->show();

    return app.exec();
}
