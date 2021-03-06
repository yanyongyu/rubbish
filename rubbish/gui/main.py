import os.path
from functools import partial
from tempfile import TemporaryFile

from PyQt5.QtGui import QIcon
from PyQt5.QtCore import (
    QUrl,
    QFileInfo,
    pyqtProperty,
    qInstallMessageHandler,
    Qt,
    QTimer,
)
from PyQt5.QtWebChannel import QWebChannel
from PyQt5.QtWebEngineWidgets import QWebEngineView
from PyQt5.QtWidgets import QWidget, QMainWindow, QApplication, QMessageBox

from .send import getFileno, receive
from rubbish.core import (
    get_prompt,
    parse,
    execute_command,
    MoreInputNeeded,
    get_history,
)

CURRENT_DIR = os.path.dirname(__file__)
ICON_FILE = os.path.join(CURRENT_DIR, "src/minilogo.png")
HTML_FILE = os.path.join(CURRENT_DIR, "src/terminal.html")
stemp = TemporaryFile(buffering=0)
rtemp = TemporaryFile(buffering=0)
etemp = TemporaryFile(buffering=0)


class Myshared(QWidget):
    def __init__(self, win: "MainWindow"):
        super().__init__()
        self.win = win
        self.input_stuck = []

    def RemoveRoute(self, str):
        str = str[2:-1]
        return str

    def PyQt52WebValue(self):
        return "666"

    def Web2PyQt5Value(self, str):
        instr = self.RemoveRoute(str)
        getFileno(stemp, instr)
        self.input_stuck.append(instr)
        self.win.history_lines.insert(0, instr)
        self.win.history.store_string(instr)
        self.win.index = 0
        # commandline
        try:
            result = parse("\n".join(self.input_stuck))
            print(result)
            self.more = False
            self.input_stuck = []
            for command in result:
                execute_command(command, stemp.fileno(), rtemp.fileno(), etemp.fileno())
        except EOFError:
            QApplication.instance().quit()
        except KeyboardInterrupt:
            self.more = False
            self.input_stuck = []
        except SyntaxError:
            jscode = 'PyQt52Result("Syntax Error!");'
            self.browser.page().runJavaScript(jscode)
            self.more = False
            self.input_stuck = []
        except MoreInputNeeded:
            self.more = True

        self.win.setResult()
        if self.more:
            prompt = "?? ????????"
        else:
            prompt = get_prompt()
        self.win.setRoute(prompt)

    value = pyqtProperty(str, fget=PyQt52WebValue, fset=Web2PyQt5Value)


class MainWindow(QMainWindow):
    # route = ""

    def __init__(self):
        super(MainWindow, self).__init__()
        self.setWindowTitle("RubbiSh")
        self.setGeometry(70, 70, 1080, 720)  # ??????????????????????????????
        self.setWindowIcon(QIcon(ICON_FILE))
        self.browser = QWebEngineView()
        self.browser.load(QUrl(f"file://{QFileInfo(HTML_FILE).absoluteFilePath()}"))
        self.setCentralWidget(self.browser)
        self.browser.loadFinished.connect(partial(self.setRoute, get_prompt()))
        self.index = 0
        self.history = get_history()
        self.history_lines = list(self.history.load_history_strings())
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.setResult)
        self.timer.start(1000)

    # ???????????????????????????
    def setRoute(self, value):
        # self.route = value
        route = value[:-2]
        st = value[-2:]
        jscode = "PyQt52Route(" + repr(route) + ", " + repr(st) + ");"
        self.browser.page().runJavaScript(jscode)

    # ??????????????????
    def setResult(self):
        value = receive(rtemp)
        jscode = "PyQt52Result(" + repr(value) + ");"
        self.browser.page().runJavaScript(jscode)
        value = receive(etemp)
        jscode = "PyQt52Result(" + repr(value) + ");"
        self.browser.page().runJavaScript(jscode)

    # def getRoute(self):
    #     return self.route

    def keyPressEvent(self, event):
        if event.key() == Qt.Key_D and event.modifiers() == Qt.ControlModifier:
            QApplication.instance().quit()
        elif event.key() == Qt.Key_C and event.modifiers() == Qt.ControlModifier:
            # ????????????????????????????????????
            self.setRoute(get_prompt())
        elif event.key() == Qt.Key_L and event.modifiers() == Qt.ControlModifier:
            jscode = "cl();"
            self.browser.page().runJavaScript(jscode)
            prompt = get_prompt()
            self.setRoute(prompt)
        elif event.key() == Qt.Key_Up:
            if self.index < len(self.history_lines) - 1:
                jscode = "getHistory(" + repr(self.history_lines[self.index]) + ");"
                self.browser.page().runJavaScript(jscode)
                self.index += 1
        elif event.key() == Qt.Key_Down:
            if self.index > 0:
                jscode = "getHistory(" + repr(self.history_lines[self.index]) + ");"
                self.browser.page().runJavaScript(jscode)
                self.index -= 1


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
