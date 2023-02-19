// eslint-disable-next-line import/no-extraneous-dependencies
import { app, BrowserWindow, ipcMain, shell } from 'electron';
import { Menubar, menubar } from 'menubar';
import path from 'path';
import { appConfig } from './config';
import { registerKeyboardShortcuts } from './keyboard-shortcuts';
import { fetchAppSettingsFromFile, writeAppSettingsToFile } from './settings';
import { initTranslateWindow } from './translate-window';
import { AppSettings, Provider } from './types';
import { isDev, debug } from './utils';

declare const MAIN_WINDOW_WEBPACK_ENTRY: string;
declare const MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY: string;

let menuBar: Menubar;
let translateWindow: BrowserWindow;
let settingsVisible: boolean;
let currentAppSettings: AppSettings;

const assetsPath =
  process.env.NODE_ENV === 'production'
    ? path.join(process.resourcesPath, 'assets')
    : path.join(app.getAppPath(), 'assets');

function passSettingsToRenderer() {
  fetchAppSettingsFromFile().then((settings) => {
    if (!menuBar.window) {
      throw new Error('Could not register settings: MenuBar BrowserWindow not found!');
    }

    currentAppSettings = settings;

    menuBar.window.webContents.send('passSettingsToRenderer', settings);
  });
}

function registerListeners() {
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

  ipcMain.on('showSettings', (_, show: boolean) => {
    debug(`[ipcMain] showSettings ${show}`);
    if (show) {
      settingsVisible = true;
      translateWindow.hide();
    } else {
      settingsVisible = false;
      translateWindow.show();
    }
  });

  ipcMain.on('writeSettingsToFile', async (_, appSettings: AppSettings) => {
    debug('[ipcMain] writeSettingsToFile');
    currentAppSettings = appSettings;
    await writeAppSettingsToFile(appSettings);
    await registerKeyboardShortcuts(appSettings, menuBar, translateWindow);
  });

  ipcMain.on('requestSettings', () => {
    debug('[ipcMain] requestSettings');
    passSettingsToRenderer();
  });

  ipcMain.on('sponsor', () => {
    debug('[ipcMain] sponsor');
    shell.openExternal('https://github.com/sponsors/ThijmenDam').catch((e) => {
      console.error(e);
    });
  });

  ipcMain.on('providerChanged', (_, provider: Provider) => {
    debug(`[ipcMain] providerChanged ${provider}`);
    // TODO: reload + inject
  });
}

function createMenubarApp() {
  menuBar = menubar({
    icon: path.join(assetsPath, '/BarTranslateIcon.png').toString(),
    index: MAIN_WINDOW_WEBPACK_ENTRY,
    preloadWindow: true,
    browserWindow: {
      skipTaskbar: true,
      show: false,
      height: appConfig.height,
      width: appConfig.width,
      transparent: true,
      frame: false,
      resizable: isDev(),
      movable: false,
      fullscreenable: false,
      minimizable: false,
      alwaysOnTop: true,
      webPreferences: {
        devTools: isDev(),
        preload: MAIN_WINDOW_PRELOAD_WEBPACK_ENTRY,
      },
      hasShadow: true,
    },
  });

  menuBar.on('ready', async () => {
    const settings = await fetchAppSettingsFromFile();

    setTimeout(() => {
      app.dock.hide();
    }, 1000);

    translateWindow = initTranslateWindow(settings, menuBar);

    if (!menuBar.window) {
      throw new Error('Menubar BrowserWindow not properly initialized!');
    }

    menuBar.window.setMenu(null);

    registerListeners();
    await registerKeyboardShortcuts(settings, menuBar, translateWindow);

    menuBar.on('show', () => {
      if (!translateWindow.isVisible() && !settingsVisible) {
        if (currentAppSettings.autoscroll) {
          translateWindow.webContents.executeJavaScript('window.scrollTo(0, 0)');
        }

        // TODO: check if dark mode is enabled, and insert CSS accordingly
        // translateWindow.webContents.insertCSS(HideRedundantElementsCSS);

        translateWindow.show();
      }
    });

    menuBar.on('focus-lost', () => {
      if (!translateWindow.isFocused()) {
        translateWindow.hide();
        menuBar.hideWindow();
      }
    });
  });
}

app
  .on('ready', createMenubarApp)
  .whenReady()
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
