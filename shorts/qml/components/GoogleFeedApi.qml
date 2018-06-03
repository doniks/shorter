import QtQuick 2.4

QtObject {
    id: rootObject

    property bool inProgress: __doc != null

    signal findResult(var result)
    signal loadResult(var result)

    property var __doc: null

    /* Find feed by keywords.
     */
    function findFeeds(searchKeywords) {
        abort(true)

        __doc = new XMLHttpRequest()
        var doc = __doc

        doc.onreadystatechange = function() {

            if (doc.readyState === XMLHttpRequest.DONE) {

                var resObj
                if (doc.status === 200) {
                    resObj = JSON.parse(doc.responseText)
                } else { // Error
                    resObj = {"responseDetails" : doc.statusText,
                        "responseStatus" : doc.status}
                }

                __doc = null
                findResult(resObj)
            }
        }

        var searchKeywordsEncoded = encodeURIComponent(searchKeywords)

        var baseUrl = "https://ajax.googleapis.com/ajax/services/feed/find?v=1.0&q="
        var finalRequest = baseUrl + searchKeywordsEncoded

        doc.open("GET", finalRequest, true);
        doc.send();
    }

    /* Load feed by URL.
     */
    function loadFeed(feedUrl, num) {
        abort(true)

        if (num)
            num = Math.min(num, 100)
        else num = 50

        __doc = new XMLHttpRequest()
        var doc = __doc

        doc.onreadystatechange = function() {

            if (doc.readyState === XMLHttpRequest.DONE) {

                var resObj
                if (doc.status == 200) {
                    resObj = JSON.parse(doc.responseText)
                } else { // Error
                    resObj = {"responseDetails" : doc.statusText,
                        "responseStatus" : doc.status}
                }

                __doc = null
                loadResult(resObj)
            }
        }

        var encodedUrl = encodeURIComponent(feedUrl)
        var baseUrl = "https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q="
        var finalRequest = baseUrl + encodedUrl

        /* Number of articles to download.
         */
        finalRequest += "&num=" + num

        /* Add some optional params.
         * May be usable:
         * hl       - host language, for example "hl=ru", default en.
         * num      - number of entries, for example "num=50", default 4, maximum 100.
         * output   - format of output, for example "output=json", may be xml, json_xml, json.
         */
        doc.open("GET", finalRequest, true);
        doc.send();
    }

    /* Param "isAbortOnly" used to preserve
     * property "__doc" in not null state.
     * inProgress binded to it so we can avoid
     * additional recalculations.
     */
    function abort(isAbortOnly) {
        if (__doc != null) {
            __doc.abort()
            if (!isAbortOnly)
                __doc = null
        }
    }

    /* Return true if some kind of errors detected.
     */
    function checkForErrors(result) {
        if (result.responseStatus == 200 ||   // HTTP OK
                result.responseStatus == 0) { // ABORTED
            return false
        }

        return true
    }
} // QtObject googleFeedApi
