// eslint-disable-next-line import/no-extraneous-dependencies
import {
  app, BrowserWindow, ipcMain, shell, globalShortcut,
} from 'electron';
import { menubar, Menubar } from 'menubar';
import * as path from 'path';
import { GoogleTranslateCSS } from './injections';

declare const MAIN_WINDOW_WEBPACK_ENTRY: string;
declare const MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY: string;

const isDev = process.env.NODE_ENV === 'development';

let menuBar: Menubar;
let translateWindow: BrowserWindow;

let settingsVisible : boolean;

const assetsPath = process.env.NODE_ENV === 'production'
  ? path.join(process.resourcesPath, 'assets')
  : path.join(app.getAppPath(), 'assets');

function createMenubarApp() {
  const appWidth = 400;
  const appHeight = 500;
  const appMargin = 4; // See MainView/styles.ts
  const appHeaderHeight = 40; // See MainView/styles.ts

  const translateWidth = appWidth - appMargin * 2;
  const translateHeight = appHeight - appHeaderHeight - appMargin * 2;

  menuBar = menubar({
    icon: path.join(assetsPath, '/BarTranslateIcon.png').toString(),
    index: MAIN_WINDOW_WEBPACK_ENTRY,
    preloadWindow: true,
    browserWindow: {
      show: false,
      height: appHeight,
      width: appWidth,
      transparent: true,
      frame: false,
      resizable: isDev,
      movable: false,
      fullscreenable: false,
      minimizable: false,
      alwaysOnTop: true,
      webPreferences: {
        devTools: isDev,
        preload: MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY,
      },
      hasShadow: true,
    },
  });

  menuBar.on('ready', () => {
    if (!menuBar.window) return;

    translateWindow = new BrowserWindow({
      show: false,
      parent: menuBar.window,
      height: translateHeight,
      width: translateWidth,
      paintWhenInitiallyHidden: false,
      x: menuBar.window.getPosition()[0] + appMargin,
      y: menuBar.window.getPosition()[1] + appHeaderHeight + appMargin,
      frame: false,
      resizable: isDev,
      movable: false,
      fullscreenable: false,
      hasShadow: false,
      minimizable: false,
      webPreferences: {
        devTools: isDev,
      },
      alwaysOnTop: true,
    });

    menuBar.window.setMenu(null);

    translateWindow.loadURL('https://translate.google.com/');

    translateWindow.on('ready-to-show', () => {
      translateWindow.webContents.insertCSS(GoogleTranslateCSS);
    });

    menuBar.on('show', () => {
      if (!translateWindow.isVisible() && !settingsVisible) {
        translateWindow.show();
        // TODO: check if dark mode is on, and insert CSS accordingly
        // translateWindow.webContents.insertCSS(GoogleTranslateCSS);
      }
    });

    menuBar.on('focus-lost', () => {
      if (!translateWindow.isFocused()) {
        translateWindow.hide();
        menuBar.hideWindow();
      }
    });

    translateWindow.on('show', () => {
      translateWindow.webContents.focus();
      translateWindow.webContents.executeJavaScript("document.querySelector('textarea').focus()");
    });

    translateWindow.on('blur', () => {
      if (!menuBar.window) return;
      if (!menuBar.window.isFocused()) {
        translateWindow.hide();
        menuBar.hideWindow();
      }
    });
  });
}

async function registerListeners() {
  /**
   * This comes from bridge integration, check bridge.ts
   */
  ipcMain.on('message', (_, message: string) => {
    // eslint-disable-next-line no-console
    console.log(message);
  });

  ipcMain.on('shutdown', () => {
    app.quit();
  });

  ipcMain.on('setSettings', (_, settings: boolean) => {
    if (settings) {
      settingsVisible = true;
      translateWindow.hide();
    } else {
      settingsVisible = false;
      translateWindow.show();
    }
  });

  ipcMain.on('sponsor', () => {
    shell.openExternal('https://paypal.me/thijmendam');
  });
}

async function registerShortcuts() {
  globalShortcut.register('Alt+K', () => {
    if (!menuBar.window?.isVisible()) {
      menuBar.showWindow();
    } else {
      menuBar.hideWindow();
    }
  });
}

app.on('ready', createMenubarApp)
  .whenReady()
  .then(registerListeners)
  .then(registerShortcuts)
  // eslint-disable-next-line no-console
  .catch((e) => console.error(e));

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createMenubarApp();
  }
});
