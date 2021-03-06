import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "service"

ApplicationWindow
{
    Dao { id: dao }
    id: root
    // TODO: Get from env vars
    property string interfaceLang: "en"
    property string defaultLang: ""
    property string defaultToLang: "ru"
    property string yandexAPI: '***'
    property string yandexDictAPI: '***'

    initialPage: Component { FirstPage {
            interfaceLang: root.interfaceLang
            defaultLang: root.defaultLang
            defaultToLang: root.defaultToLang
            yandexAPI: root.yandexAPI
            yandexDictAPI: root.yandexDictAPI
        }
    }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}
