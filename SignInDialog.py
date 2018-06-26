import cx_Oracle as orcl
from PyQt5 import QtCore
from PyQt5.QtWidgets import *
from PyQt5.uic import loadUi

from MainWindow import MainWindow

version = "0.0.1"
connectionString = "c##r1507006/p1507006@127.0.0.1/orcldb"


class SignInDialog(QDialog):
    def __init__(self):
        super(SignInDialog, self).__init__()
        loadUi("./ui/SignInDialog.ui", self)
        self.setWindowTitle("We Cheaters")

        # Signals and slots
        self.signinButton.clicked.connect(self.signIn)
        self.cancelButton.clicked.connect(self.cancel)
        self.signupButton.clicked.connect(self.sign_up)

    def sign_up(self):
        fname = self.signupNameLineEdit.text()
        email = self.signupUserLineEdit.text()
        password = self.signupPassLineEdit.text()
        if signUpCheck(email):
            try:
                con = orcl.connect(connectionString)
                cur = con.cursor()
                cur.prepare(
                    "insert into users (name, pass, date_created, email) values (:name1, :pass1, sysdate, :email1)")
                cur.execute(None, {"name1": fname, "pass1": password, "email1": email})
                cur.close()
                con.commit()
                con.close()
                self.hide()
                startMainWindow(self, email, "Signed up successfully")
            except Exception as e:
                print(e)
        else:
            showError(self, 2)

    def cancel(self):
        self.close()

    def signIn(self):
        userName = self.signinUserLineEdit.text()
        password = self.signinPassLineEdit.text()
        if signInCheck(userName, password):
            self.hide()
            startMainWindow(self, userName, "Signed in successfully")
        else:
            showError(self, 1)


def showError(parent, error=1):
    errorMessage = QMessageBox(parent)
    errorMessage.setWindowTitle("Wrong")
    if error is 1:
        errorMessage.setText("Wrong user email or password!!!")
    elif error is 2:
        errorMessage.setText("User with this email already exists!!!")
    errorMessage.setWindowModality(QtCore.Qt.WindowModal)
    errorMessage.show()


def signInCheck(userName, password):
    con = orcl.connect(connectionString)
    cur = con.cursor()
    cur.prepare("select * from users where email = :email and pass = :pass")
    cur.execute(None, {'email': userName, 'pass': password})
    res = cur.fetchall()
    if len(res) > 0:
        cur.close()
        con.close()
        return True
    else:
        cur.close()
        con.close()
        return False


def signUpCheck(userName):
    con = orcl.connect(connectionString)
    cur = con.cursor()
    cur.prepare("select email from users where email = :userName")
    cur.execute(None, {"userName": userName})
    res = cur.fetchall()
    if len(res) > 0:
        cur.close()
        con.close()
        return False
    else:
        cur.close()
        con.close()
        return True


def startMainWindow(parent, email, statusText):
    mainWindow = MainWindow(parent, email, statusText)
    mainWindow.show()
