import os

from threading import Timer
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QUrl, QFileInfo, pyqtProperty
from PyQt5.QtWebChannel import QWebChannel
from PyQt5.QtWebEngineWidgets import QWebEngineView
from PyQt5.QtWidgets import QWidget, QMainWindow, QApplication, QMessageBox

CURRENT_DIR = os.path.dirname(__file__)
ICON_FILE = os.path.join(CURRENT_DIR, "src/minilogo.png")
HTML_FILE = os.path.join(CURRENT_DIR, "src/terminal.html")


class Myshared(QWidget):

    def __init__(self, win: "MainWindow"):
        super().__init__()
        self.win = win

    def RemoveRoute(self, str):
        str = str[len(self.win.getRoute()):]
        return str

    def PyQt52WebValue(self):
        return "666"

    def Web2PyQt5Value(self, str):
        instr = self.RemoveRoute(str)
        # parse(str)
        QMessageBox.information(self, "网页来的信息", instr)

    value = pyqtProperty(str, fget=PyQt52WebValue, fset=Web2PyQt5Value)


class MainWindow(QMainWindow):
    route = ""

    def __init__(self):
        super(MainWindow, self).__init__()
        self.setWindowTitle("RubbiSh")
        self.setGeometry(70, 70, 1080, 720)  # 窗口的初始位置和大小
        self.setWindowIcon(QIcon(ICON_FILE))
        self.browser = QWebEngineView()
        self.browser.load(QUrl(QFileInfo(HTML_FILE).absoluteFilePath()))
        self.setCentralWidget(self.browser)

    # 传输当前路径调用：
    def setRoute(self, value):
        self.route = value
        jscode = "PyQt52Route(\"" + value + "\");"
        self.browser.page().runJavaScript(jscode)

    # 传输结果调用
    def setResult(self, value):
        jscode = "PyQt52Result(\"" + value + "\");"
        self.browser.page().runJavaScript(jscode)

    def getRoute(self):
        return self.route


def main():
    app = QApplication([])
    win = MainWindow()
    channel = QWebChannel()
    shared = Myshared(win)
    channel.registerObject("con", shared)
    win.browser.page().setWebChannel(channel)
    t = Timer(5, win.setRoute, ["123"])
    t.start()

    win.show()
    app.exit(app.exec_())


if __name__ == '__main__':
    main()
