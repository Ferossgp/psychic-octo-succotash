import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "service"

ApplicationWindow
{
    Dao { id: dao }
    // TODO: Get from env vars
    property string defaultLang: ""
    property string yandexAPI: ""

    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
