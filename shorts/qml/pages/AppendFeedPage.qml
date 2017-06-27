/*
 * Copyright (C) 2013, 2014, 2015, 2016
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "../components"
import "../utils/databasemodule_v2.js" as DB
import "../."

Page {
    id: appendFeedPage

    objectName: "appendfeedpage"
    visible: false

    property int selectedCount: 0
    property bool resultsReceived: false // Indicates that at least once results were received.

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Add feeds")

        ActivityIndicator {
            id: checkRunning

            visible: googleFeedApi.inProgress
            running: googleFeedApi.inProgress

            anchors {
                verticalCenter: parent.verticalCenter
                right: pageHeader.trailingActionBar.left
                rightMargin: units.gu(1)
            }
        }

        trailingActionBar.actions: [
            Action {
                iconName: "ok"
                text: i18n.tr("Next")
                enabled: !googleFeedApi.inProgress && selectedCount > 0

                onTriggered: {
                    var selectedFeeds = []
                    for (var i = 0; i < searchResultsModel.count; i++) {
                        var curItem = searchResultsModel.get(i)

                        if (curItem.isSelected)
                            selectedFeeds.push(curItem)
                    }

                    chooseTopicPageLoader.doAction(function(page) {
                        pageStack.push(page, appendFeedPage, false, {"feedsToAdd" : selectedFeeds, "parentPage" : appendFeedPage})
                    })
                }
            }
        ]
    }

    function reloadPageContent() {
        tfFeedUrl.text = ""
        resultsReceived = false
        clearModelDependData()
    }

    /* Clear model and model's depend data.
     * Currently only selectedCount.
     */
    function clearModelDependData() {
        searchResultsModel.clear()
        selectedCount = 0
    }

    // -------------------------------------       GOOGLE API

    Connections {
        target: googleFeedApi

        onFindResult: {
            resultsReceived = true

            if ( result.responseStatus !== 200 ) {
                // No need to show dialog in case of abort.
                if (result.responseStatus !== 0) {
                    PopupUtils.open(errorDialogComponent, appendFeedPage,
                                    {"text" : i18n.tr("Failed to perform a feed search by keyword"),
                                        "title" : i18n.tr("Search failed")})
                    console.log(JSON.stringify(result))
                }
                return
            }

            clearModelDependData()

            var entries = result.responseData.entries

            for (var i = 0; i < entries.length; i++) {
                // Skip entries with empty URL.
                if (!entries[i].url)
                    continue

                searchResultsModel.append({"url" : entries[i].url,
                                              "title" : entries[i].title,
                                              "description" : entries[i].contentSnippet,
                                              "link" : entries[i].link,
                                              "isSelected" : false})
            }
        }

        onLoadResult: {
            resultsReceived = true

            if ( result.responseStatus !== 200 ) {
                // No need to show dialog in case of abort.
                if (result.responseStatus !== 0) {
                    PopupUtils.open(errorDialogComponent, appendFeedPage,
                                    {"text" : i18n.tr("Failed to perform a feed search by URL"),
                                        "title" : i18n.tr("Search failed")})
                    console.log(JSON.stringify(result))
                }
                return
            }

            clearModelDependData()

            var feed = result.responseData.feed

            searchResultsModel.append({"url" : feed.feedUrl,
                                          "title" : feed.title,
                                          "description" : feed.description,
                                          "link" : feed.link,
                                          "isSelected" : false})
        }
    }

    GoogleFeedApi {
        id: googleFeedApi
    }

    // -------------------------------------       GOOGLE API

    Column {
        id: appendFeedColumn

        anchors.top: pageHeader.bottom
        anchors.topMargin: units.gu(2)
        width: parent.width
        spacing: units.gu(2)

        TextField {
            objectName: "tfFeedUrl"
            id: tfFeedUrl

            placeholderText: i18n.tr("Enter an URL")

            width: parent.width - units.gu(4)
            // height:units.gu(5)
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            primaryItem: Icon {
                height: parent.height * 0.5
                width: height
                anchors.verticalCenter: parent.verticalCenter
                name: "search"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (Qt.inputMethod.visible)
                            tfFeedUrl.accept()
                    }
                }
            }

            onAccepted: accept()

            function accept() {
                Qt.inputMethod.hide()
                var userInput = text

                if (!userInput)
                    return

                // Very simple logic, URL if there are no spaces and contains dots.
                // But simple not means that it is wrong.
                var isUrlEntered = ( userInput.indexOf(" ") === -1 &&                     
                                     userInput.indexOf(".") !== -1)

                if (isUrlEntered) {
                    console.log("url")
                    if (userInput.indexOf("http://") !== 0) {
                        userInput = "http://" + userInput
		    }

                    // FIXME: find the actual title etc without the broken google api
                    // googleFeedApi.loadFeed(userInput)
                    searchResultsModel.append(
                        { "url" : userInput,
                          "title" : userInput,
                          "description" : userInput,
                          "link" : userInput,
                          "isSelected" : true
                            
                        } )
                }
                else 
                {
                    console.log("not url")
                    googleFeedApi.findFeeds(text)
                }
            }
        }

        ListItem.Header {

            ListItem.ThinDivider { }

            text: i18n.tr("Search results")
        }
    } // Column


    ListView {
        id: searchResults
        objectName: "feedpagelistview"

        clip: true
        anchors {
            bottom: parent.bottom
            top: appendFeedColumn.bottom
            left: parent.left
            right: parent.right
        }

        model: searchResultsModel

        delegate: ListItem.Standard {
            text: model.title
            objectName: "feedpagelistitem-" + model.title

            control: CheckBox {
                anchors.verticalCenter: parent.verticalCenter

                objectName: "feedCheckbox-" + model.title
                onCheckedChanged: {
                    searchResultsModel.setProperty(index, "isSelected", checked)
                    if (checked)
                        selectedCount++
                    else selectedCount--
                }
            }
        }
    }

    ListModel {
        id: searchResultsModel
    }

    Label {
        visible: searchResultsModel.count == 0 && resultsReceived
        anchors.centerIn: parent
        text: i18n.tr("No feeds")
        fontSize: "large"
    }
}
