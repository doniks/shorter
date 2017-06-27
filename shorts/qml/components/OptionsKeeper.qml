import QtQuick 2.4
import Qt.labs.settings 1.0
// import U1db 1.0 as U1db

/* New interface for options.
 * Currently it is just facade on U1DB.
 */
Item {

    property int fontSize
    property bool useDarkTheme
    property bool useListMode
    property bool useGoogleSearch
    property string yadToken: ""

    Component.onCompleted: {
        fontSize = getFontSize()
        useDarkTheme = getUseDarkTheme()
        useListMode = getUseListMode()
        useGoogleSearch = getUseGoogleSearch()
        yadToken = getYadToken()
    }

    onFontSizeChanged: setFontSize(fontSize)
    onUseDarkThemeChanged: setUseDarkTheme(useDarkTheme)
    onUseListModeChanged: setUseListMode(useListMode)
    onUseGoogleSearchChanged: setUseGoogleSearch(useGoogleSearch)
    onYadTokenChanged: setYadToken(yadToken)

    function getFontSize() {
        return settings.fontSize
    }

    function setFontSize(value) {
        settings.fontSize = value
    }

    function getUseDarkTheme() {
        return settings.useDarkTheme
    }

    function setUseDarkTheme(value) {
        settings.useDarkTheme = value
    }

    function getUseListMode() {
        return settings.useListMode
    }

    function setUseListMode(value) {
        settings.useListMode = value
    }

    function dbVersion() {
        return settings.dbVersion
    }

    function setDbVersion(value) {
        settings.dbVersion = value
    }

    function getUseGoogleSearch() {
        return settings.useGoogleSearch
    }

    function setUseGoogleSearch(value) {
        settings.useGoogleSearch = value
    }

    function getYadToken() {
        return settings.yadToken
    }

    function setYadToken(value) {
        settings.yadToken = value
    }

    Settings {
        id: settings
        property string dbVersion: "1.2"
        property bool useDarkTheme: false
        property bool useListMode: false
        property bool useGoogleSearch: false
        property int fontSize: 1
        property string yadToken: ""
    }
} // Item
