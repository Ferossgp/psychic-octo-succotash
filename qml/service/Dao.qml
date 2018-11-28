import QtQuick 2.0
import QtQuick.LocalStorage 2.0

Item {
    property var database;

    Component.onCompleted: {
        database = LocalStorage.openDatabaseSync("Translator", "1.0");
        database.transaction(function(tx) {
            tx.executeSql("DROP TABLE HistoryTable");
        });
        database.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS HistoryTable(
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        langOriginal TEXT,
                        langTranslation TEXT,
                        text TEXT,
                        translated TEXT,
                        starred INTEGER)");
        });
    }

    function retrieveHistoryItems(callback) {
        database = LocalStorage.openDatabaseSync("Translator", "1.0");
        database.readTransaction(function(tx) {
            var result = tx.executeSql("SELECT * FROM HistoryTable");
            callback(result.rows)
        });
    }

    function retrieveStarredItem(callback) {
        database = LocalStorage.openDatabaseSync("Translator", "1.0");
        database.readTransaction(function(tx) {
            var result = tx.executeSql("SELECT * FROM HistoryTable WHERE starred = 1");
            callback(result.rows)
        });
    }

    function createHistoryItem(langOriginal, langTranslation, text, translated, starred) {
        database = LocalStorage.openDatabaseSync("Translator", "1.0");
        database.transaction(function(tx) {
            tx.executeSql("INSERT INTO HistoryTable(langOriginal, langTranslation, text, translated, starred)
                                VALUES(?, ?, ?, ?, ?)", [langOriginal, langTranslation, text, translated, starred]);
        });
    }

    function updateHistoryItem(id, langOriginal, langTranslation, text, translated, starred) {
        database = LocalStorage.openDatabaseSync("Translator", "1.0");
        database.transaction(function(tx) {
            tx.executeSql("UPDATE HistoryTable SET langOriginal = ?, langTranslation = ?, text = ?, translated = ?, starred = ?
                                 WHERE id = ?", [langOriginal, langTranslation, text, translated, starred, id]);
        });
    }

    function starHistoryItem(id, starred) {
        database = LocalStorage.openDatabaseSync("Translator", "1.0");
        database.transaction(function(tx) {
            tx.executeSql("UPDATE HistoryTable SET starred = ?
                                 WHERE id = ?", [starred, id]);
        });
    }

    function removeHistoryItem(id) {
        database = LocalStorage.openDatabaseSync("Translator", "1.0");
        database.transaction(function(tx) {
            tx.executeSql("DELETE FROM HistoryTable WHERE id = ?", [id]);
        });
    }

}
