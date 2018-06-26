from PyQt5.QtWidgets import *
from PyQt5.uic import loadUi
import cx_Oracle as orcl

connectionstring = "c##r1507006/p1507006@127.0.0.1/orcldb"


class MainWindow(QMainWindow):
    def __init__(self, parent, email, statusText):
        super(MainWindow, self).__init__(parent)
        loadUi("./ui/MainWindow.ui", self)
        self.setWindowTitle("We Cheaters")
        self.statusBar().showMessage(statusText)
        self.email = email
        self.populateTables()
        self.addShortcutButton.clicked.connect(self.addShortcutDialog)
        self.refreshButton.clicked.connect(self.populateTables)

    def addShortcutDialog(self):
        addShortcut = QDialog(self)
        loadUi("./ui/AddShortcutDialog.ui", addShortcut)
        addShortcut.addButton.clicked.connect(lambda: addNewShortcut(self,
                                                                     addShortcut.shortcutNameLineEdit.text(),
                                                                     addShortcut.shortcutDescLineEdit.text()
                                                                     )
                                              )
        addShortcut.exec_()

    def deleteShortcut(self):
        id = self.sender().text()[8:]
        self.sender().setText("deleted")
        con = orcl.connect(connectionstring)
        cur = con.cursor()
        query = "delete from shortcut where id = " + id
        print(query)
        try:
            cur.execute(query)
        except Exception as e:
            print(format(e))
        cur.close()
        con.commit()
        con.close()

    def populateTables(self):
        myShortcutTable = self.tabWidget.widget(0).children()[1]
        topShortcutTable = self.tabWidget.widget(1).children()[1]
        userTable = self.tabWidget.widget(2).children()[1]
        while myShortcutTable.rowCount() > 0:
            myShortcutTable.removeRow(0)
        while topShortcutTable.rowCount() > 0:
            topShortcutTable.removeRow(0)
        while userTable.rowCount() > 0:
            userTable.removeRow(0)
        try:
            con = orcl.connect(connectionstring)
            cur = con.cursor()

            query = "select id, name, description, uploader, to_char(upload_date) from shortcut " \
                    "where uploader = '" + self.email + "'"
            cur.execute(query)
            res = cur.fetchall()

            # add the row to QTableWidget
            myShortcutTable.insertRow(0)
            for row in res:
                myShortcutTable.insertRow(myShortcutTable.rowCount())
                for j in range(len(row)):
                    item = QTableWidgetItem()
                    item.setText(str(row[j]))
                    myShortcutTable.setItem(myShortcutTable.rowCount() - 1, j, item)
                btn = QPushButton("delete: " + str(row[0]), self)
                # btn.setText("Delete")
                btn.clicked.connect(self.deleteShortcut)
                myShortcutTable.setCellWidget(myShortcutTable.rowCount() - 1, myShortcutTable.columnCount() - 1, btn)

            query = "select id, name, description, uploader, to_char(upload_date), reputation from shortcut " \
                    "where ROWNUM <= 10" \
                    "order by reputation"
            cur.execute(query)
            res = cur.fetchall()

            # add the row to QTableWidget
            topShortcutTable.insertRow(0)
            for row in res:
                topShortcutTable.insertRow(topShortcutTable.rowCount())
                for j in range(len(row)):
                    item = QTableWidgetItem()
                    item.setText(str(row[j]))
                    topShortcutTable.setItem(topShortcutTable.rowCount() - 1, j, item)

            # add the row to QTableWidget
            query = "select name, email, to_char(date_created) from users"
            cur.execute(query)
            res = cur.fetchall()
            userTable.insertRow(0)
            for row in res:
                userTable.insertRow(userTable.rowCount())
                for j in range(len(row)):
                    item = QTableWidgetItem()
                    item.setText(str(row[j]))
                    userTable.setItem(userTable.rowCount() - 1, j, item)
            cur.close()
            con.close()
        except Exception as e:
            print(e)


def addNewShortcut(parent, name, desc = ""):
    if name is "":
        return
    try:
        con = orcl.connect(connectionstring)
        cur = con.cursor()
        print(desc)
        cur.prepare("insert into shortcut(id, name, description, upload_date, uploader) "
                    "values((select shortcut from autogen), :name, '" + desc + "', sysdate, :uploader)")
        cur.execute(None, {"name": name, "uploader": parent.email})
        parent.statusBar().showMessage("Successfully added")
        cur.close()
        con.commit()
        con.close()
    except Exception as e:
        print(e)
