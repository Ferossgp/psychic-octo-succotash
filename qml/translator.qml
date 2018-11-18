import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "service"

ApplicationWindow
{
    Dao { id: dao }
    initialPage: Component { HistoryPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
