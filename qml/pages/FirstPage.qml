import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0

Page {
    id: page

    allowedOrientations: Orientation.All
    property var translation;
    property bool placeholderVisible: translation.text.length === 0
    property string placeholder: qsTr("Start typing...")
    property string yandexAPI
    property string yandexDictAPI
    property string defaultLang: 'en'
    property string defaultToLang: 'ru'

    // To enable PullDownMenu, place our content in a SilicaFlickable

    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("History")
                onClicked: pageStack.push(Qt.resolvedUrl("HistoryPage.qml"))
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column
            y: Theme.paddingLarge
            width: page.width
            spacing: Theme.paddingLarge

            Row {
                id: selectLanguage
                x: Theme.paddingLarge

                width: parent.width - 2 * Theme.paddingLarge
                spacing: Theme.paddingMedium

                ComboBox {
                    property var dataModel: languagesModel
                    id: fromLangComboBox
                    width:  parent.width / 2 - Theme.paddingMedium * 3

                    label: qsTr("From:")
                    menu: ContextMenu {
                        Repeater {
                            model: fromLangComboBox.dataModel

                            MenuItem {
                                text: model.value
                                truncationMode: TruncationMode.Fade
                                onClicked: fromLangComboBox.selectLang(index)
                            }
                        }
                    }
                    function selectLang(index) {
                        currentIndex = index;
                    }
                    onCurrentItemChanged: {
                        var length = dataModel.count;
                        if (currentIndex !== 0) {
                            return;
                        }

                        for (var i = 0; i < length; i++) {
                            if (dataModel.get(i).key === defaultLang) {
                                currentIndex = i;
                            }
                        }
                    }
                }

                IconButton {
                    width: Theme.paddingLarge * 2
                    height: fromLangComboBox.height
                    icon.source: "image://theme/icon-s-retweet?" + (pressed
                                                                    ? Theme.highlightColor
                                                                    : Theme.primaryColor)
                    onClicked: {
                        originalTextEdit.text = translatedTextArea.text;
                        var to = toLangComboBox.currentIndex;
                        toLangComboBox.currentIndex = fromLangComboBox.currentIndex;
                        fromLangComboBox.currentIndex = to;
                    }
                }

                ComboBox {
                    property var dataModel : languagesModel
                    id: toLangComboBox
                    x: Theme.paddingLarge
                    width:  parent.width / 2 - Theme.paddingMedium * 3
                    label: qsTr("To:")

                    menu: ContextMenu {
                        Repeater {
                            model: toLangComboBox.dataModel

                            MenuItem {
                                text: model.value
                                truncationMode: TruncationMode.Fade
                                onClicked: toLangComboBox.selectLang(index)
                            }
                        }
                    }
                    function selectLang(index) {
                        currentIndex = index;
                    }
                    onCurrentItemChanged: {
                        var length = dataModel.count;
                        if (currentIndex !== 0) {
                            return;
                        }

                        for (var i = 0; i < length; i++) {
                            if (dataModel.get(i).key === defaultToLang) {
                                currentIndex = i;
                            }
                        }
                    }

                }
            }

            TextArea {
                x: Theme.paddingLarge;
                id: originalTextEdit;
                width: parent.width - Theme.paddingLarge;
                label: qsTr("");
                font.pixelSize: Theme.fontSizeMedium;
                color: placeholderVisible ? Theme.secondaryColor : Theme.primaryColor
                wrapMode: TextEdit.Wrap;
                placeholderText: placeholder
                inputMethodHints: Qt.ImhNoPredictiveText;
                onTextChanged: {
                    translationModel.inputText = text;
                    translationModel.reload()
                }
                Component.onCompleted: {
                    dao.createHistoryItem(fromLangComboBox.currentIndex.value,
                                          toLangComboBox.currentIndex.value,
                                          translationModel.inputText,
                                          translatedTextArea.text,
                                          false);
                }
            }
            TextArea {
                id: translatedTextArea;
                x: Theme.paddingLarge;
                property var dataModel : translationModel
                width: parent.width;
                text: dataModel.count ? dataModel.get(0).translatedText : "";
                font.pixelSize: Theme.fontSizeMedium;
                color: placeholderVisible ? Theme.secondaryColor : Theme.primaryColor
                wrapMode: TextEdit.Wrap;
                inputMethodHints: Qt.ImhNoPredictiveText;
            }

        }

        XmlListModel {
            id: languagesModel
            source: "https://translate.yandex.net/api/v1.5/tr/getLangs?key=" + yandexAPI + "&ui=" + defaultLang
            query: "/Langs/langs/Item"
            XmlRole {name: "value"; query: "@value/string()"}
            XmlRole {name: "key"; query: "@key/string()"}
        }

        XmlListModel {
            id: translationModel
            property string inputText: ""
            property string lang: {
                var from = fromLangComboBox;
                var to = toLangComboBox;
                var fromEntry = from.dataModel.get(from.currentIndex);
                var toEntry = to.dataModel.get(to.currentIndex);
                console.log(JSON.stringify(fromEntry));
                console.log(JSON.stringify(toEntry));
                return (fromEntry ? fromEntry.key : defaultLang) + "-" + (toEntry ? toEntry.key : defaultToLang);
            }
            source: "https://translate.yandex.net/api/v1.5/tr/translate?key=" + yandexAPI + "&text=" + inputText + "&lang=" + lang
            query: "/Translation"
            XmlRole {name: "translatedText"; query: "text/string()"}
            onStatusChanged: {
                if (status !== XmlListModel.Ready) {
                    return;
                }
                var length = translationModel.count;
                for (var i = 0; i < length; i++) {
                    console.log(JSON.stringify(translationModel.get(i)));
                }

            }
        }

        Component.onCompleted: {
            translation = {text: "", translated: ""};
        }
    }
}
