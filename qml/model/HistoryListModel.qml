import QtQuick 2.0

ListModel {

    function addHistory(id, langOriginal, langTranslation, text, translated, starred) {
        append({
                   id: id,
                   langOriginal: langOriginal,
                   langTranslation: langTranslation,
                   text: text,
                   translated: translated,
                   starred: starred,
               });
    }

    function changePreference(index, state) {
        set(index, {starred: state})
    }
}
