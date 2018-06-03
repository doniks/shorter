#include "utilities.h"
#include "xml2json.hpp"

Utilities::Utilities(QObject *parent) :
    QObject(parent)
{
//    qDebug() << "path: " << QDir::currentPath() ;
//    QFile xmlFile("xml");
//    xmlFile.open(QIODevice::ReadOnly | QIODevice::Text);

//    qDebug() << "json: " << xmlToJson(QString(xmlFile.readAll())).size();
}

QJsonObject Utilities::xmlToJson(const QString &xml)
{
    qDebug() << "xmlToJson\n" ;
    QByteArray ba = xml.toLocal8Bit();
    char* ch = ba.data();
    const std::string json = xml2json(ch);
    qDebug() << "json.length=" << json.length() << "\n";
//    qDebug() << "json: " << QString::fromStdString(json) ;
    return QJsonDocument::fromJson(QString::fromStdString(json).toLocal8Bit()).object();
}

QStringList Utilities::htmlGetImg(const QString &html)
{
    QRegExp imgTagRegex("\\<img[^\\>]*src\\s*=\\s*\"([^\"]*)\"[^\\>]*\\>", Qt::CaseInsensitive);
    imgTagRegex.setMinimal(true);
    QStringList urlmatches;
    QStringList imgmatches;
    int offset = 0;
    while( (offset = imgTagRegex.indexIn(html, offset)) != -1)
    {
        offset += imgTagRegex.matchedLength();
        imgmatches.append(imgTagRegex.cap(0)); // Should hold complete img tag
        urlmatches.append(imgTagRegex.cap(1)); // Should hold only src property
    }
    return urlmatches;
}

QJsonObject Utilities::test()
{
    QFile xmlFile("xml");
    xmlFile.open(QIODevice::ReadOnly | QIODevice::Text);

    QJsonObject obj = xmlToJson(QString(xmlFile.readAll()));
    return obj;
}
