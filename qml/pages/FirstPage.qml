import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0
import '../utils.js' as Utils

Page {
    id: page

    allowedOrientations: Orientation.All
    property var translation;
    property bool placeholderVisible: translation.text.length === 0
    property string placeholder: qsTr("Start typing...")
    property string yandexAPI
    property string yandexDictAPI
    property string interfaceLang: 'en'
    property string defaultLang: 'en'
    property string defaultToLang: 'ru'
    property var limitStartTime: new Date()
    property int refreshesThisSecond: 0


    Timer {
        id: timer
    }

    function delay(delayTime, cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);;
        timer.triggered.connect(function release () {
            timer.triggered.disconnect(cb);
            timer.triggered.disconnect(release);
        });
        timer.start();
        return function() {
            timer.restart();
        };
    }

    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            quickSelect: true
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
                    property var detectModel: detectLangModel
                    property bool inited: false
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
                    function selectLangFromString(lang) {
                        var length = dataModel.count;
                        for (var i = 0; i < length; i++) {
                            if (dataModel.get(i).key === lang) {
                                currentIndex = i;
                                return;
                            }
                        }
                        currentIndex = -1;
                        currentItem = null;
                    }

                    onCurrentItemChanged: {
                        var length = dataModel.count;
                        if (inited) {
                            return;
                        }
                        inited = true;
                        selectLangFromString(defaultLang);
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
                        toLangComboBox.selectLang(fromLangComboBox.currentIndex);
                        fromLangComboBox.selectLang(to);
                    }
                }

                ComboBox {
                    property var dataModel : languagesModel
                    property bool inited: false
                    id: toLangComboBox
                    x: Theme.paddingLarge
                    width:  parent.width / 2 - Theme.paddingMedium * 3
                    label: qsTr("To:    ")

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
                        if (inited) {
                            return;
                        }
                        inited = true;

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
                onTextChanged: delay(500, function(){
                    detectLangModel.inputText = originalTextEdit.text;
                    detectLangModel.reload();
                    if (fromLangComboBox.currentIndex < 0) {
                        return;
                    }
                    translationModel.inputText = originalTextEdit.text;
                    translationModel.reload();
                    synonymsModel.inputText = originalTextEdit.text;
                    synonymsModel.reload();
                    saveButton.pressed = false;
                })

            }

            TextArea {
                id: translatedTextArea;
                x: Theme.paddingLarge;
                property var dataModel : translationModel
                width: parent.width;
                readOnly: true
                text: dataModel.count ? dataModel.get(0).translatedText : "";
                font.pixelSize: Theme.fontSizeMedium;
                color: placeholderVisible ? Theme.secondaryColor : Theme.primaryColor
                wrapMode: TextEdit.Wrap;
                inputMethodHints: Qt.ImhNoPredictiveText;
            }

            Component {
                id: sectionHeading
                Label {
                    width: parent.width
                    text: section
                    color: Theme.highlightColor
                    font.bold: true
                    font.pixelSize: Theme.fontSizeSmall
                    z: -1
                }
            }

            Rectangle {
                width: parent.width - 120
                height: 600
                anchors.horizontalCenter: parent.horizontalCenter
                color: 'transparent'

                ListView {
                    id: synonymsListView
                    anchors.fill: parent
                    width: parent.width
                    model: synonymsModel
                    delegate: Text {
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeMedium
                        text: def
                    }
                    clip: true
                    snapMode: ListView.SnapToItem
                    section.property: "pos"
                    section.criteria: ViewSection.NextLabelAtEnd
                    section.delegate: sectionHeading
                }
            }

            Button {
                id: saveButton
                property bool pressed: false
                text: qsTr('Save')
                visible: translationModel.inputText && translatedTextArea.text
                enabled: !pressed
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    pressed = true;
                    synonymsModel.inputText = originalTextEdit.text;
                    synonymsModel.reload();
                    dao.createHistoryItem(fromLangComboBox.currentIndex.value,
                                          toLangComboBox.currentIndex.value,
                                          translationModel.inputText,
                                          translatedTextArea.text,
                                          false);
                }
            }
        }

        XmlListModel {
            id: languagesModel
            source: "https://translate.yandex.net/api/v1.5/tr/getLangs?key=" + yandexAPI + "&ui=" + interfaceLang
            query: "/Langs/langs/Item"
            XmlRole {name: "value"; query: "@value/string()"}
            XmlRole {name: "key"; query: "@key/string()"}
        }

        XmlListModel {
            id: detectLangModel
            property string inputText: ""
            source: "https://translate.yandex.net/api/v1.5/tr/detect?key=" + yandexAPI + "&text=" + inputText
            query: "/DetectedLang"
            XmlRole {name: "lang"; query: "@lang/string()"}
            onStatusChanged: {
                if (status === XmlListModel.Ready) {
                    fromLangComboBox.selectLangFromString(detectLangModel.get(0).lang);
                }
            }
        }

        XmlListModel {
            id: translationModel
            property string inputText: ""
            property string lang: {
                var from = fromLangComboBox;
                var to = toLangComboBox;
                var fromEntry = from.dataModel.get(from.currentIndex);
                var toEntry = to.dataModel.get(to.currentIndex);
                return (fromEntry ? fromEntry.key : defaultLang) + "-" + (toEntry ? toEntry.key : defaultToLang);
            }
            source: "https://translate.yandex.net/api/v1.5/tr/translate?key=" + yandexAPI + "&text=" + inputText + "&lang=" + lang
            query: "/Translation"
            XmlRole {name: "translatedText"; query: "text/string()"}
        }

        XmlListModel {
            id: synonymsModel
            property string inputText: ""
            property string lang: {
                var from = fromLangComboBox;
                var to = toLangComboBox;
                var fromEntry = from.dataModel.get(from.currentIndex);
                var toEntry = to.dataModel.get(to.currentIndex);
                return (fromEntry ? fromEntry.key : defaultLang) + "-" + (toEntry ? toEntry.key : defaultToLang);
            }
            source: {
                if (inputText.length === 0) {
                    return "";
                }
                return "https://dictionary.yandex.net/api/v1/dicservice/lookup?key=" + yandexDictAPI + "&text=" + inputText + "&lang=" + lang
            }
            query: "/DicResult/def/tr"
            XmlRole {name: "def"; query: "text/string()"}
            XmlRole {name: "pos"; query: "@pos/string()"}
        }

        Component.onCompleted: {
            translation = {text: "", translated: "", synonyms: []};
        }
    }
}
