from PyQt5 import QtWidgets
from PyQt5.QtWidgets import QApplication, QMainWindow
import sys, random

def createWindow(WINWIDTH = 1280, WINHEIGHT = 720, TITLE="Window"):
    app = QApplication(sys.argv)
    win = QMainWindow()
    win.setGeometry(random.randint(200, 1200), random.randint(200, 800), WINWIDTH, WINHEIGHT)
    win.setWindowTitle(TITLE)
    
    return {'APP': app, 'WIN': win,'WINWIDTH': WINWIDTH, 'WINHEIGHT': WINHEIGHT}

def createText(win, xpos=None, ypos=None, content="[EMPTY TEXT]"):
    if xpos == None:
        xpos = random.randint(0, win['WINWIDTH']-15)
    if ypos == None:
        ypos = random.randint(0, win['WINHEIGHT']-15)
    label = QtWidgets.QLabel(win['WIN'])
    label.setText(content)
    label.move(xpos, ypos)

def close(win):
    win['WIN'].show()
    sys.exit(win['APP'].exec_())