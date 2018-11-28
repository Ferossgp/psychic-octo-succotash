import QtQuick 2.0
import Sailfish.Silica 1.0
import "../service"

CoverBackground {
    id: page
    property var translations: [];
    property var id: 0;

    CoverPlaceholder{
        id: emptyHistory
        anchors.verticalCenter: page.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: true
        text: qsTr("You don't have any starred item in history right now")
    }

    Column {
        id: learner
        width: page.width

        Label {
            id: originalWord
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 50
        }

        Label {
            id: transaltedWord
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 50
        }
        CoverActionList {
            id: refreshAction
            enabled: true

            CoverAction {
                iconSource: "image://theme/icon-cover-refresh"
                onTriggered: retreiveStarred();
            }

        }

        CoverActionList{
            id: actionList
            enabled: false

            CoverAction {
                id: nextBtn
                iconSource: "image://theme/icon-cover-next"
                onTriggered: retreiveStarred();
            }
        }
    }

    Component.onCompleted: {
        retreiveStarred();
    }

    function getId(tr){
        if (id !== undefined){
            id = Math.floor(Math.random() * tr.length);
        } else{
            if (tr.length === id){
                id = 0;
            }else{
                id++;
            }
        }
        return id;
    }

    function getWord(wordList) {
        if (wordList.length != 0){
            emptyHistory.enabled = false;
            emptyHistory.text = "";
            actionList.enabled = true;
            refreshAction.enabled = false;
            id = getId(wordList);
            originalWord.text = wordList[id].text;
            transaltedWord.text = wordList[id].translated
        }
    }

    function retreiveStarred() {
        dao.retrieveStarredItem(function(historyItems) {
            if(historyItems.length !== 0) {
                translations = historyItems;
                getWord(translations);
            }
        });
    }
}
