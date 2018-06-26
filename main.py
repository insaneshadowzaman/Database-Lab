import sys
from PyQt5.QtWidgets import QApplication
from SignInDialog import SignInDialog


def main():
    app = QApplication(sys.argv)
    sign_in_dialog = SignInDialog()
    sign_in_dialog.show()
    sys.exit(app.exec_())


main()
