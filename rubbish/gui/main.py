import sys
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtWebEngineWidgets import *


class MainWindow(QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__()
        self.setWindowTitle('RubbiSh')
        self.setGeometry(70, 70, 1080, 720)  # 窗口的初始位置和大小
        self.setWindowIcon(QIcon('src/minilogo.png'))
        self.browser = QWebEngineView()
        self.browser.load(
            QUrl(QFileInfo("src/terminal.html").absoluteFilePath()))
        self.setCentralWidget(self.browser)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    win = MainWindow()
    win.show()
    app.exit(app.exec_())
