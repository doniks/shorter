import QtQuick 2.4
import QtQuick.XmlListModel 2.0

import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import Ubuntu.Components.Popups 1.3

import "../utils/databasemodule_v2.js" as DB
import "../utils/imgSeparator.js" as ImageUtils
import "../utils/dateutils.js" as DateUtils

// below import for non-google usage
import "../nongoogle"

Item {
    id: networkManagerRoot

    signal downloadFinished(int tagId)
    signal downloadStarted(int tagId)

    property string operationStatus: "success"
    property bool __useGFA: optionsKeeper.useGoogleSearch

    function updateFeeds(feedsArray, topicId) {
        d.updateFeeds(feedsArray, topicId)
    }

    function cancelDownload() {
        d.cancelDownload()
    }

    /* All private method are inside QtObject.
     */
    QtObject {
        id: d

        property var feedList: []                 // Feed list to update.
        property var currentFeed                  // Current downloading feed.
        property int tagId: 0                     // Tag to update.

        /* Method updates feeds one by another.
         * Input: array of objects, each should include
         * source, link and id (of feed in DB) properties.
         */
        function updateFeeds(feedsArray, topicId) {
            tagId = topicId || 0

            downloadStarted(tagId)

            feedList = feedsArray
            operationStatus = "success"
            updateNextFeed()
        }

        // For inner usage only.
        function updateNextFeed() {
            if (feedList.length == 0) {
                downloadFinished(tagId)
                return
            }

            currentFeed = feedList.shift()
            if (__useGFA) {
                googleFeedApi.loadFeed(currentFeed.source)
            } else { 
	        nonGoogleFeedApi.loadFeed(currentFeed.source)
	    }
        }

        function cancelDownload() {
            feedList = []
            operationStatus = "abort"
            if (__useGFA)
                googleFeedApi.abort()
            else 
                nonGoogleFeedApi.abort()
        }

        function updateFeedInfo(feedId, feedLink, responseData) {
            var entries = responseData.feed.entries
            var f = responseData.feed

            DB.updateFeedByXml(feedId, f.feedUrl === f.link ? feedLink : f.link, // Sometimes google fails and sends site link equal to feed url.
                                                              f.description, f.title)
            console.log(" -------- UPDATE INFO -------- ")
            console.log(f.title, f.link, f.feedUrl, f.description)

            console.time("addArticlesEx")

            var newArticles = []
            for (var i = 0; i < entries.length; i++) {
                var e = entries[i]

                // Grab image from for article.
                var articleImage = ImageUtils.grabArticleImage(e)
                e.content = clearFromBadTags(e.content)

                var temp = {
                    "title": e.title,
                    "content": e.content,
                    "link": e.link,
                    "author": e.author,
                    "description": e.contentSnippet,
                    "pubDate": DateUtils.parseDate(e.publishedDate),
                    "guid": Qt.md5(e.content + e.publishedDate),
                    "image" : articleImage,
                    "media_groups" : e.mediaGroups //== undefined ? "" : JSON.stringify(e.mediaGroups),
                }

                newArticles.push(temp)
            }

            /* Add new articles to DB and restore 'read' status of some of them. */
            try {
                DB.addArticlesEx(newArticles, feedId)
            } catch (e) {
                console.log("Exception:", JSON.stringify(e))
            }

            console.timeEnd("addArticlesEx")
        }

        function updateFeedInfoNg(feedId, feedLink, responseData) {
            var entries = responseData.item
            var f = responseData

            var fde = f.description == undefined ? "" : f.description["#text"] == undefined ? f.description : f.description["#text"]
            var fti = f.title == undefined ? "" : f.title["#text"] == undefined ? f.title : f.title["#text"]

            DB.updateFeedByXml(feedId, feedLink, fde, fti)
            console.log(" -------- UPDATE INFO (NG) -------- ")
            console.log(fti, feedLink, f.feedUrl, fde)

            console.time("addArticlesEx")

            var newArticles = []
            var maxLength = entries.length > 50 ? 50 : entries.length
            for (var i = 0; i < maxLength; i++) {
                var e = entries[i]

                var ti = e.title == undefined ? "" : e.title["#text"] == undefined ? e.title : e.title["#text"]
                var li = e.link == undefined ? "" : e.link["#text"] == undefined ? e.link : e.link["#text"]
                var au = e.author == undefined ? "" : e.author["#text"] == undefined ? e.author : e.author["#text"]
                var creator = e.creator == undefined ? "" : e.creator["#text"] == undefined ? e.creator : e.creator["#text"]
                var de = e.description == undefined ? "" : e.description["#text"] == undefined ? e.description : e.description["#text"]
                var pu = e.pubDate == undefined ? "" : e.pubDate["#text"] == undefined ? e.pubDate : e.pubDate["#text"]
                var co = e.content == undefined ? "" : e.content["#text"] == undefined ? e.content : e.content["#text"]

                var articleImage = utilities.htmlGetImg(de)
                if (!articleImage.length)
                    articleImage = utilities.htmlGetImg(co)

                var temp = {
                    "title": ti,
                    "content": co ? co : de,
                    "link": li,
                    "author": creator ? creator : au ,
                    "description": de,
                    "pubDate": DateUtils.parseDate(pu),
                    "guid": Qt.md5(li + pu),
                    "image" : articleImage.length ? articleImage[0] : "",
                    "media_groups" : ""
                }

                console.log(i, temp.title)
                newArticles.push(temp)
            }

            /* Add new articles to DB and restore 'read' status of some of them. */
            try {
                DB.addArticlesEx(newArticles, feedId)
            } catch (e) {
                console.log("Exception:", JSON.stringify(e))
            }

            console.timeEnd("addArticlesEx")
        }

        function clearFromBadTags(content) {
            /* Remove non empty too. Useless anyway.
             */
            content = content.replace(/alt=".*?"/g, "")
            content = content.replace(/title=".*?"/g, "")
            return content
        }

        property var googleFeedApi: GoogleFeedApi {
            onLoadResult: {
                console.log("googleFeedApi", result.rss, result.responseStatus)
                if (result.responseStatus !== 200) {
                    console.log("XML NETWORK GFA:", JSON.stringify(result))
                    if (operationStatus == "success")
                        operationStatus = "withErrors"
                } else d.updateFeedInfo(d.currentFeed.id, d.currentFeed.link, result.responseData)

                d.updateNextFeed()
            }
        } // GFA

        property var nonGoogleFeedApi: XmlNetwork {
            onLoadResult: {
                console.log("nonGoogleFeedApi", result.rss, result.responseStatus)
                if ( result.rss ) {
                    console.log("result.rss")
                    d.updateFeedInfoNg(d.currentFeed.id, d.currentFeed.link, result.rss.channel)
                } else if (result.feed) {
                    console.log("result.feed")
                    // I think this means Atom format instead of RSS format, and
                    // that currently doesn't work
                    // but, e.g., ubports uses this!
                    // FIXME!
                    if (operationStatus == "success")
                        operationStatus = "withErrors"
                } else {
                    console.log("!result.rss", 
                                "rss", result.rss, 
                                "json", result.json, 
                                "atom", result.atom, 
                                "feed", result.feed,
                                "xml", result.xml,
                                "xmlns", result.xmlns
                               )
                    console.log("operationStatus", operationStatus)
                    console.log("XML NETWORK NGA:", JSON.stringify(result))
                    if (operationStatus == "success")
                        operationStatus = "withErrors"
                }

                d.updateNextFeed()
            }
        } // NGA
    } // QtObject
}
