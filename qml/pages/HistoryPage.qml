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
                    highlighted: starred
                    Label {
                        id: historyText
                        text: model.text
                        truncationMode: TruncationMode.Fade
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                    }
                    Label {
                        id: sumLabel
                        text: translated
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                    }
                    menu: ContextMenu {
                        MenuItem {
                            text: starred ? qsTr("Unstar") : qsTr("Star")
                            onClicked: {
                                dao.starHistoryItem(id, !starred);
                                model.starred = !starred;
                            }
                        }
                        MenuItem {
                            text: qsTr("Remove")
                            onClicked:  {
                                dao.removeHistoryItem(id);
                                listView.model.remove(index);
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
                    console.log(JSON.stringify(historyItem));
                    listView.model.addHistory(historyItem.id,
                                              historyItem.langOriginal,
                                              historyItem.langTranslation,
                                              historyItem.text,
                                              historyItem.translated,
                                              !!historyItem.starred);
                }
            } else {
                emptyHistory.text = qsTr("You don't have any item in history right now");
            }
        });
    }
}
