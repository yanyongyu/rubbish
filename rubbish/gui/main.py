import os.path
from functools import partial
from tempfile import TemporaryFile

from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QUrl, QFileInfo, pyqtProperty, qInstallMessageHandler, Qt
from PyQt5.QtWebChannel import QWebChannel
from PyQt5.QtWebEngineWidgets import QWebEngineView
from PyQt5.QtWidgets import QWidget, QMainWindow, QApplication, QMessageBox

from .send import getFileno, receive
from rubbish.core import get_prompt, parse, execute_command, MoreInputNeeded

CURRENT_DIR = os.path.dirname(__file__)
ICON_FILE = os.path.join(CURRENT_DIR, "src/minilogo.png")
HTML_FILE = os.path.join(CURRENT_DIR, "src/terminal.html")
stemp = TemporaryFile(buffering=0)
rtemp = TemporaryFile(buffering=0)


class Myshared(QWidget):
    def __init__(self, win: "MainWindow"):
        super().__init__()
        self.win = win
        self.input_stuck = []

    def RemoveRoute(self, str):
        str = str[2:]
        return str

    def PyQt52WebValue(self):
        return "666"

    def Web2PyQt5Value(self, str):
        instr = self.RemoveRoute(str)
        fileno = getFileno(stemp, instr)
        self.input_stuck.append(instr)
        # commandline
        try:
            result = parse(instr)
            print(result)
            self.more = False
            self.input_stuck = []
            for command in result:
                result_code = execute_command(command, stemp.fileno(), rtemp.fileno())
        except EOFError:
            QApplication.instance().quit()
        except KeyboardInterrupt:
            self.more = False
            self.input_stuck = []
        except SyntaxError:
            self.more = False
            self.input_stuck = []
        except MoreInputNeeded:
            self.more = True

        self.win.setResult()
        if self.more:
            prompt = f"· ····"
        else:
            prompt = get_prompt()
        self.win.setRoute(prompt)

    value = pyqtProperty(str, fget=PyQt52WebValue, fset=Web2PyQt5Value)


class MainWindow(QMainWindow):
    # route = ""

    def __init__(self):
        super(MainWindow, self).__init__()
        self.setWindowTitle("RubbiSh")
        self.setGeometry(70, 70, 1080, 720)  # 窗口的初始位置和大小
        self.setWindowIcon(QIcon(ICON_FILE))
        self.browser = QWebEngineView()
        self.browser.load(QUrl(f"file://{QFileInfo(HTML_FILE).absoluteFilePath()}"))
        self.setCentralWidget(self.browser)
        self.browser.loadFinished.connect(partial(self.setRoute, get_prompt()))

    # 传输当前路径调用：
    def setRoute(self, value):
        # self.route = value
        route = value[:-2]
        st = value[-2:]
        jscode = "PyQt52Route(" + repr(route) + ", " + repr(st) + ");"
        self.browser.page().runJavaScript(jscode)

    # 传输结果调用
    def setResult(self):
        value = receive(rtemp)
        jscode = "PyQt52Result(" + repr(value) + ");"
        self.browser.page().runJavaScript(jscode)

    # def getRoute(self):
    #     return self.route

    def keyPressEvent(self, event):
        if event.key() == Qt.Key_D and event.modifiers() == Qt.ControlModifier:
            QApplication.instance().quit()
        elif event.key() == Qt.Key_C and event.modifiers() == Qt.ControlModifier:
            # 结束正在运行的程序或命令
            self.setRoute(get_prompt())
        elif event.key() == Qt.Key_L and event.modifiers() == Qt.ControlModifier:
            jscode = "cl();"
            self.browser.page().runJavaScript(jscode)
            prompt = get_prompt()
            self.setRoute(prompt)


def main():
    app = QApplication([])
    win = MainWindow()
    # qInstallMessageHandler(lambda *args: None)
    channel = QWebChannel()
    shared = Myshared(win)
    channel.registerObject("con", shared)
    win.browser.page().setWebChannel(channel)
    # t = Timer(5, win.setRoute, ["123"])
    # t.start()
    win.show()
    app.exit(app.exec_())
    stemp.close()
    rtemp.close()


if __name__ == "__main__":
    main()
