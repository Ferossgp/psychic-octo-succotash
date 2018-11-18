import QtQuick 2.0
import Sailfish.Silica 1.0
import "../service"
import "../model"

Page {
    id: page

    Label {
        id: emptyHistory
        color: Theme.secondaryHighlightColor
        y: page.height / 2
        anchors.horizontalCenter: parent.horizontalCenter
    }


    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        PageHeader {
            id: header
            title: qsTr("History")
            width: parent.width
        }
        Column {
            id: column
            width: parent.width
            anchors.top: header.bottom
            spacing: Theme.paddingLarge

            SilicaListView {
                id: listView
                model: HistoryListModel { id: historyListModel }
                width: parent.width
                VerticalScrollDecorator {}
                height: page.height - header.height - Theme.paddingLarge * 2
                clip: true
                delegate: ListItem {
                    Label {
                        id: historyText
                        text: text
                        truncationMode: TruncationMode.Fade
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                    }
                    Label {
                        id: sumLabel
                        text: translatedText
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                    }
                    menu: ContextMenu {
                        MenuItem {
                            text: star ? qsTr("Unstar") : qsTr("Star")
                            onClicked: {
                                listView.model.changePreference(id, !star)
                                dao.starHistoryItem(id, !star);
                            }
                        }
                        MenuItem {
                            text: qsTr("Remove")
                            onClicked:  {
                                dao.removeHistoryItem(id);
                                listView.model.remove(model.index);
                            }
                        }
                    }
                }
                Component.onCompleted: displayHistory()
            }
        }
    }

    function displayHistory() {
        listView.model.clear();
        dao.retrieveHistoryItems(function(historyItems) {
            emptyHistory.text = "";
            if(historyItems.length !== 0) {
                for (var i = 0; i < historyItems.length; i++) {
                    var historyItem = historyItems.item(i);
                    listView.model.addHistory(historyItem.id,
                                              historyItem.langOriginal,
                                              historyItem.langTranslation,
                                              historyItem.text,
                                              historyItem.translated);
                }
            } else {
                emptyHistory.text = qsTr("You don't have any item in history right now");
            }
        });
    }
}
