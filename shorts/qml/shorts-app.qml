import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3

import "./pages"
import "./tabs"
import "./components"
import "./utils/databasemodule_v2.js" as DB

import "./content"
import "./nongoogle"

MainView {
    id: mainView

    objectName: "mainView"
//    applicationName: "doniks.shorter"
    anchorToKeyboard: true

    width: units.gu(46)
    height: units.gu(84)
    focus: true

    Component.onCompleted: {
        QuickUtils.mouseAttached = true
        configureDb()
    }

    function configureDb() {
        var dbParams = {
            "isRefreshRequired" : false,
            "oldDbVersion" : optionsKeeper.dbVersion(),
            "newDbVersion" : ""
        }

        DB.adjustDb(dbParams)

        if (dbParams.oldDbVersion != dbParams.newDbVersion) {
            optionsKeeper.setDbVersion(dbParams.newDbVersion)
        }

        if (dbParams.isRefreshRequired)
             refresh()

        reloadMainView()
    }

    /* Refresh current topic or all feeds if we are in the Shorts.
     */
    function refresh() {
        var topicId = pageStack.currentTopicId()
        console.log("Refresh", topicId)

        console.log("REFRESH TOPIC", topicId)
        if (topicId == -2) {
            refreshSavedTab()
            return
        }

        var feeds = topicId !== 0 ? DB.loadFeedsFromTag(topicId) : DB.loadFeeds()

        var feedarray = []
        for (var i = 0; i< feeds.rows.length; i++)
            feedarray.push(feeds.rows.item(i))
        networkManager.updateFeeds(feedarray, topicId)
    }

    function reloadViews(tagId) {
        tagId = tagId || 0

        if (tagId == 0)
            shortsTab.reloadTab("reloadViews")
        else topicTab.reloadTab("reloadViews")
    }

    function reloadMainView() {
        mainPage.reloadPageContent()
    }

    // refresh "Saved" Tab
    function refreshSavedTab() {
        savedTab.reloadTab()
    }

    function showArticle(model, index) {
        articlePageLoader.doAction(function(page) {
            page.setFeed(model, index)
            pageStack.push(page, null, pageStack.useOrdinaryLayout)
        })
    }

    /* -------------------------- Visuals ---------------------------- */
    AdaptivePageLayout {
        id: pageStack

        objectName: "pageStack"
        primaryPage: mainPage
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: -1 // SDK BUG?
        }
        focus: true

        property bool useOrdinaryLayout: true
        property Page lastPushedPage: null  // Last page that was pushed to the first column of APL.

        // TODO Workaround.
        function currentTopicId() {
            return lastPushedPage && lastPushedPage.hasOwnProperty("topicId") ? lastPushedPage.topicId : 0
        }

        function push(page, sourcePage, toNext, props) {
            if (!page)
                return

            // Sanitize input.
            sourcePage = sourcePage || lastPushedPage || mainPage
            toNext = !!toNext

            // Add to appropriate column.
            if (toNext)
                pageStack.addPageToNextColumn(sourcePage, page, props)
            else pageStack.addPageToCurrentColumn(sourcePage, page, props)

            if (page.reloadPageContent)
                page.reloadPageContent()

            if (!toNext)
                lastPushedPage = page
        }

        function pop(page) {
            pageStack.removePages(page)
        }

        /* Used for keeping status in sync across tabs.
         */
        function updateStatusInModels(article, status) {
            var tagId = article.tagId
            var articleId = article.id

            savedTab.updateStatusInModel(articleId, status)
            shortsTab.updateStatusInModel(articleId, status)
            topicTab.updateStatusInModel(articleId, status)
        }

        /* Used for keeping favourite in sync across tabs.
         */
        function updateFavouriteInModels(article, fav) {
            var tagId = article.tagId
            var articleId = article.id

            savedTab.updateFavouriteInModel(article, fav) // SavedTab requires article object, not articleId.
            shortsTab.updateFavouriteInModel(articleId, fav)
            topicTab.updateFavouriteInModel(articleId, fav)
        }

        Keys.onPressed: {
            console.log(objectName, event.key.toString(16), event.modifiers.toString(16))

            // Refresh on F5.
            if (event.key === Qt.Key_F5)
                refresh()

            if (event.modifiers & Qt.ControlModifier) {
                if (event.key === Qt.Key_A) {
                    appendFeedPageLoader.doAction(function(page) { pageStack.push(page, mainPage) }) // pageStack.push(appendFeedPage, mainPage)
                } else if (event.key === Qt.Key_R) {
                    refresh()
                }
            }

            if (event.key == Qt.Key_Left) {
                articlePageLoader.doAction(function(page) { page.articleView.showPrevArticle() })
            } else if (event.key == Qt.Key_Right) {
                articlePageLoader.doAction(function(page) { page.articleView.showNextArticle() })
            }
        }

        MainPage {
            id: mainPage

            objectName: "mainPage"
        }

        SavedTab {
            id: savedTab

            objectName: "Tab1"
            tabTitle: i18n.tr("Saved")
            topicId: -2
        }

        ShortsTab {
            id: shortsTab

            objectName: "Tab0"
            tabTitle: i18n.tr("Shorter")
            topicId: 0
        }

        TopicTab {
            id: topicTab

            objectName: "TopicTab"
        }

        PageLoader {
            id: appendFeedPageLoader
            sourceComponent: AppendFeedPage { }
        }

        PageLoader {
            id: appendNgFeedPageLoader
            sourceComponent: AppendNGFeedPage { }
        }

        PageLoader {
            id: chooseTopicPageLoader
            sourceComponent: ChooseTopicPage {
                id: chooseTopicPage
                Connections {
                    target: chooseTopicPage
                    onTopicChoosen: globalEventHandler.handleEvent(type)
                }
            }
        }

        PageLoader {
            id: createTopicPageLoader
            sourceComponent: CreateTopicPage {
                id: createTopicPage
                Connections {
                    target: createTopicPage
                    onTopicAdded: globalEventHandler.handleEvent(type)
                }
            }
        }

        PageLoader {
            id: editFeedPageLoader
            sourceComponent: EditFeedPage {
                id: editFeedPage
                Connections {
                    target: editFeedPage
                    onFeedEdited: globalEventHandler.handleEvent(type)
                }
            }
        }



        PageLoader {
            id: articlePageLoader
            sourceComponent: ArticleViewPage {
                id: articlePage
                Connections {
                    target: articlePage.articleView

                    onArticleStatusChanged: pageStack.updateStatusInModels(article, status)
                    onArticleFavouriteChanged: pageStack.updateFavouriteInModels(article, favourite)
                }
            }
        }

        PageLoader {
            id: topicManagementPageLoader
            sourceComponent: TopicManagementPage {
                id: topicManagement
                Connections {
                    target: topicManagement
                    onTopicDeleted: globalEventHandler.handleEvent(type)
                }
            }
        }

        PageLoader {
            id: settingsPageLoader
            sourceComponent: SettingsPage { }
        }

        PageLoader {
            id: sharePageLoader
            sourceComponent: SharePage { }
        }

        PageLoader {
            id: yadLoginPageLoader
            sourceComponent: YadLoginPage {
                id: yadLoginPage
                onAuthPassed: {
                    console.log("TOKEN", token)
                    optionsKeeper.yadToken = token
                    // networkManager.token = token TODO
                    pageStack.pop(yadLoginPage)
                }
            }
        }
    } // PageStack

    /* -------------------------- Utils ---------------------------- */

    QtObject {
        id: globalEventHandler

        function handleEvent(type) {
            console.log("globalEventHandler", type)
            switch(type)
            {
            case "topicAdded":
                reloadMainView()
                topicManagementPageLoader.doAction(function(page) { page.reloadTopics() } )
                break;
            case "topicChoosen":
                reloadMainView()
                topicManagementPageLoader.doAction(function(page) { page.reloadTopics() } )
                //networkManager.updateFeeds(addedFeeds, topicId)
                break;
            case "feedEdited":
                reloadMainView()
                topicManagementPageLoader.doAction(function(page) { page.reloadTopics() } )
                break;
            case "topicDeleted":
                reloadMainView()
                break;
            }
        }
    }

    NetworkManager {
        id: networkManager

        onDownloadFinished: {
            reloadViews(tagId)
            reloadMainView()
        }

        onDownloadStarted: {
            PopupUtils.open(refreshWaitDialogComponent, null)
        }
    }

    OptionsKeeper {
        id: optionsKeeper
    }

    /* -------------------------- Components ---------------------------- */

    Component {
        id: refreshWaitDialogComponent

        Dialog {
            id: refreshWaitDialog
            objectName: "refreshWaitDialog"

            title: i18n.tr("Checking for new articles")

            ActivityIndicator {
                objectName: "activityindicator"
                running: true
            }

            Button {
                text: i18n.tr("Cancel")
                objectName: "refreshCancel"
                color: UbuntuColors.orange
                onClicked: {
                    networkManager.cancelDownload()
                    PopupUtils.close(refreshWaitDialog)
                }
            }

            Connections {
                target: networkManager

                onDownloadFinished: {
                    PopupUtils.close(refreshWaitDialog)
                    if ( networkManager.operationStatus === "withErrors" ) {
                        PopupUtils.open(errorDialogComponent, pageStack,
                                        {"text" : i18n.tr("Perhaps some of the channels have not been updated."),
                                            "title" : i18n.tr("Errors occurred during the update")})
                    }
                }
            }
        } // Dialog
    } // Component

    Component {
        id: errorDialogComponent

        Dialog {
            id: errorDialog

            Button {
                text: i18n.tr("Ok")
                objectName: "errordialogbutton"
                onClicked: PopupUtils.close(errorDialog)
            }
        }
    } // Component

    // Shader workaround.
    Rectangle {
        z: -1
        anchors.fill: parent
    }

    layer.effect: DarkModeShader {}
    layer.enabled: optionsKeeper.useDarkTheme
}
