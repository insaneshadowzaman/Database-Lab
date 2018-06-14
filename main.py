import sys
from PyQt5.QtWidgets import QApplication
from SignInDialog import SignInDialog


def main():
    app = QApplication(sys.argv)
    signInDialog = SignInDialog()
    signInDialog.show()
    sys.exit(app.exec_())


main()
