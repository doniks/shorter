import QtQuick 2.4
import Ubuntu.Components 1.3
// import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3
import QtGraphicalEffects 1.0

import "../components"
import "../utils/databasemodule_v2.js" as DB
import "../."

Page {
    id: mainPage

    objectName: "mainpage"
    flickable: null
    visible: true

    header: PageHeader {
        visible: false
    }

    Item {
        id: itemHeader

        anchors {
            left: parent.left
            right: parent.right
        }
        height: units.gu(12)
        z: 1

        Image {
            source: Qt.resolvedUrl("/img/qml/icons/back1.jpg")
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
        }

        Rectangle {
            color: "#88000000"
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            width: units.gu(25)

            Label {
                id: textTitle
                text: "Shorter"
                color: "#EB6536"
                style: Text.Raised
                styleColor: "black"
                textFormat: Text.PlainText
                font.pixelSize: units.gu(7)
                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    top: parent.top
                }
            }

            Label {
                id: textSubtitle
                text: "News Reader"
                color: "#EB6536"
                style: Text.Raised
                styleColor: "black"
                textFormat: Text.PlainText
                textSize: Label.Medium
                anchors {
                    left: textTitle.left
                    top: textTitle.bottom
                    topMargin: -units.gu(0.5)
                }
            }

//            ActionIcon {
//                id: actionSetting
//                objectName:"actionSetting"
//                icon {
//                    width: units.gu(3)
//                    color: "#EB6536"
//                    name: "settings"
//                }
//                text {
//                    text: i18n.tr("Settings")
//                    color: "white"
//                    font.italic: true
//                    style: Text.Raised
//                }
//                anchors {
//                    right: parent.right
//                    rightMargin: units.gu(1)
//                    bottom: parent.bottom
//                    bottomMargin: units.gu(0.5)
//                }
//                onClicked: pageStack.push(settingsPage, mainPage)
//            }
        }



        Rectangle {
            color: "#404244"
            anchors {
                right: parent.right
                left: parent.left
                bottom: parent.bottom
            }
            height: units.gu(0.25)
        }
    }

    GridView {
        id: topicListView

        model: topicModel
        anchors {
            left: parent.left
            top: itemHeader.bottom
            right: parent.right
            bottom: parent.bottom
            bottomMargin: units.gu(4) // Because of bottom edge tip.
        }

        header: Column {
            anchors {
                right: parent.right
                left: parent.left
            }

            Item {
                width: parent.width
                height: units.gu(11)

                ListItem {
                    anchors {
                        left: parent.left
                        right: parent.horizontalCenter
                        top: parent.top
                        bottom: parent.bottom
                    }
                    Icon {
                        color: "#EB6536"
                        width: units.gu(6)
                        height: width
                        name: "rssreader-app-symbolic"
                        anchors {
                            centerIn: parent
                            verticalCenterOffset: -units.gu(1.5)
                        }

                        Text {
                            text: i18n.tr("All articles")
                            color: "#404244"
                            font.bold: true
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                top: parent.bottom
                                topMargin: units.gu(0.5)
                            }
                        }
                    }
                    onClicked: showTopicById(0)
                }

                ListItem {
                    anchors {
                        left: parent.horizontalCenter
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    Icon {
                        color: "#EB6536" // color: "lightgrey"
                        width: units.gu(6)
                        height: width
                        name: "scope-manager"
                        anchors {
                            centerIn: parent
                            verticalCenterOffset: -units.gu(1.5)
                        }

                        Text {
                            text: i18n.tr("Saved")
                            color: "#404244"
                            font.bold: true
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                top: parent.bottom
                                topMargin: units.gu(0.5)
                            }
                        }
                    }
                    onClicked: showTopicById(-1)
                }


                Rectangle {
                    color: "lightgrey"
                    width: 1
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: units.gu(1)
                        bottom: parent.bottom
                        bottomMargin: units.gu(1)
                    }
                }

                Rectangle {
                    color: "lightgrey"
                    width: parent.width
                    height: 1
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }
                }
            }

            Rectangle {
                color: "#404244"
                anchors {
                    right: parent.right
                    left: parent.left
                }
                height: units.gu(2)
            }

            Rectangle {
                id: topicRect
                color: "transparent"
                width: parent.width
                height: units.gu(3)

                Label {
                    text: i18n.tr("Topics")
                    color: "black"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: units.gu(1)
                    }
                    //font.italic: true
                    textSize: Label.Medium
                }

                Rectangle {
                    color: "lightgrey"
                    width: parent.width
                    height: 1
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }
                }

                ActionIcon {
                    id: editTopicsAction
                    objectName:"editTopicsAction"
                    icon {
                        width: units.gu(2.5)
                        color: "#EB6536" // color: "grey"
                        name: "edit"
                    }
                    text {
                        text: i18n.tr("Edit")
                        color: "#404244"
                        font.italic: true
                    }
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    onClicked: topicManagementPageLoader.doAction( function(page) { pageStack.push(page, mainPage) }) //pageStack.push(topicManagement, mainPage)
                }
            }
        }

        boundsBehavior: Flickable.StopAtBounds
        cellWidth: width / 2
        cellHeight: units.gu(10)

        delegate: ListItem {
            height: topicListView.cellHeight
            width: topicListView.cellWidth

            divider.visible: false

            Text {
                color: "#404244"
                anchors {
                    centerIn: parent
                    verticalCenterOffset: -units.gu(0.5)
                }

                text: model.title
                font.weight: Font.DemiBold
            }

            Rectangle {
                color: "lightgrey"

                height: 1
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    leftMargin: (model.index % 2) ? 0 : units.gu(2)
                    right: parent.right
                    rightMargin: (model.index % 2) ? units.gu(2) : 0
                }
            }

            Rectangle {
                color: "lightgrey"

                width: 1
                anchors {
                    right: parent.right
                    top: parent.top
                    topMargin: units.gu(1)
                    bottom: parent.bottom
                    bottomMargin: units.gu(1)
                }
                visible: !(model.index % 2)
            }

            Label {
                color: "grey"
                anchors {
                    //left: parent.left
                    //leftMargin: units.gu(1)
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: units.gu(0.5)
                }
                textSize: Label.XSmall
                text: "Feeds: %1, articles: %2/%3".arg(model.feed_count).arg(model.article_unread_count).arg(model.article_count)
            }

            onClicked: showTopicById(model.topicId, model.title)
        }
    }

    Rectangle {
        color: "white"
        z: 1
        height: units.gu(4)
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        ActionIcon {
            id: settingsBottomAction
            objectName:"settingsBottomAction"
            icon {
                width: units.gu(2.5)
                color: "#EB6536"
                name: "settings"
            }
            text {
                text: i18n.tr("Settings")
                color: "#404244"
                font.italic: true
            }
            height: parent.height
            anchors {
                left: parent.left
                right: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            onClicked: settingsPageLoader.doAction(function(page) { pageStack.push(page, mainPage) }) // pageStack.push(settingsPage, mainPage)
        }

        ActionIcon {
            id: addReadsBottomAction
            objectName:"addReadsBottomAction"
            icon {
                width: units.gu(2.5)
                color: "#EB6536"
                name: "add"
            }
            text {
                text: i18n.tr("Add feeds")
                color: "#404244"
                font.italic: true
            }
            height: parent.height
            anchors {
                right: parent.right
                left: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            onClicked: appendFeedPageLoader.doAction(function(page) { pageStack.push(page, mainPage) }) //pageStack.push(appendFeedPage, mainPage)
        }

        Rectangle {
            color: "#404244"
            anchors {
                right: parent.right
                left: parent.left
                top: parent.top
            }
            height: units.gu(0.25)
        }
    }

    function reloadPageContent() {
        var tags = DB.loadTagsEx()
        topicModel.clear()
        for (var i = 0; i< tags.rows.length; i++) {
            //console.log(tags.rows.item(i).feed_count, tags.rows.item(i).article_count)
            topicModel.append({ "title" : tags.rows.item(i).name,
                                  "feed_count" : tags.rows.item(i).feed_count,
                                  "article_count" : tags.rows.item(i).article_count,
                                  "article_unread_count" : tags.rows.item(i).article_unread_count,
                                  "topicId" : tags.rows.item(i).id })
        }
    }

    function showTopicById(topicId, topicTitle) {
        console.log("ShowTopicById", topicId)
        var pageToAdd
        if (topicId === 0)
            pageToAdd = shortsTab
        else if (topicId === -1)
            pageToAdd = savedTab
        else {
            topicTab.topicId = topicId
            topicTab.tabTitle = topicTitle
            pageToAdd = topicTab
        }

        pageToAdd.reloadTab("selectedInMainPage")
        pageStack.push(pageToAdd, mainPage)
    }

    ListModel {
        id: topicModel
    }

    Label {
        visible: topicModel.count == 0
        anchors.centerIn: parent
        text: i18n.tr("No topics")
        fontSize: "large"
    }
}
