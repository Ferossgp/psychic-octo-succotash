import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0

Page {
    id: page

    allowedOrientations: Orientation.All
    property var translation;
    property bool placeholderVisible: translation.text.length === 0
    property string placeholder: qsTr("Start typing...")

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
                            }
                        }
                    }
                    function selectLang(id) {
                        fromLangComboBox.currentIndex = fromLangComboBox.dataModel.getIndexById(id)
                    }

                }

                IconButton {
                    width: Theme.paddingLarge * 2
                    height: fromLangComboBox.height
                    icon.source: "image://theme/icon-s-retweet?" + (pressed
                                                                    ? Theme.highlightColor
                                                                    : Theme.primaryColor)
                    onClicked: {
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
                            }
                        }
                    }
                    function selectLang(id) {
                        toLangComboBox.currentIndex = toLangComboBox.dataModel.getIndexById(id)
                    }

                }
            }

            TextArea {
                x: Theme.paddingLarge;
                id: originalTextEdit;
                width: parent.width - Theme.paddingLarge;
                label: qsTr("");
                text: placeholderVisible ? placeholder : translation.text;
                font.pixelSize: Theme.fontSizeMedium;
                color: placeholderVisible ? Theme.secondaryColor : Theme.primaryColor
                wrapMode: TextEdit.Wrap;
                inputMethodHints: Qt.ImhNoPredictiveText;
                onCursorPositionChanged: {
                    if (placeholderVisible) cursorPosition = 0;
                }
                onFocusChanged: {
                    if (focus) {
                        color = placeholderVisible ? Theme.secondaryHighlightColor : Theme.highlightColor;
                    } else {
                        color = placeholderVisible ? Theme.secondaryColor : Theme.primaryColor
                        translationModel.inputText = text;
                        translationModel.reload()
                    }
                }
                onTextChanged: {
                    if (focus && text !== placeholder && placeholderVisible) {
                        text = text.replace(placeholder, "");
                        color = Theme.highlightColor;
                        cursorPosition += 1;
                        placeholderVisible = false;
                    } else if (text.length === 0 && !placeholderVisible) {
                        text = placeholder;
                        color = Theme.secondaryHighlightColor;
                        placeholderVisible = true;
                    }
                }
                Component.onCompleted: {
                    dao.createHistoryItem(fromLangComboBox.currentIndex.value,
                                          toLangComboBox.currentIndex.value,
                                          translationModel.inputText,
                                          translatedText, false);
                }
            }
            TextArea {
                x: Theme.paddingLarge;
                id: originalTextEdit2;
                width: parent.width;
                text: translation.translated;
                font.pixelSize: Theme.fontSizeMedium;
                color: placeholderVisible ? Theme.secondaryColor : Theme.primaryColor
                wrapMode: TextEdit.Wrap;
                inputMethodHints: Qt.ImhNoPredictiveText;
                onTextChanged: {
                    text = translation.translated
                }
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
            property string lang: fromLangComboBox.currentItem.key + "-" + toLangComboBox.currentItem.key
            source: "https://translate.yandex.net/api/v1.5/tr/translate?key=" + yandexAPI + "&text=" + inputText + "&lang=" + lang
            query: "/Translation"
            XmlRole {name: "translatedText"; query: "text/string()"}
        }

        Component.onCompleted: {
            translation = {text: "", translated: "Text"};
        }
    }
}
