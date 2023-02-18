// eslint-disable-next-line import/no-extraneous-dependencies
import { BrowserWindow } from 'electron';
import { Menubar } from 'menubar';
import { appConfig } from './config';
import { CSSInjections, JSInjections } from './injections';
import { AppSettings } from './types';
import { isDev } from './utils';

function executeJavaScript(translateWindow: BrowserWindow, code: string) {
  if (translateWindow.isVisible()) {
    translateWindow.webContents.executeJavaScript(code).catch((e) => {
      console.error(e);
    });
  }
}

export function swapLanguages(provider: AppSettings['provider'], translateWindow: BrowserWindow) {
  executeJavaScript(translateWindow, JSInjections[provider].clearTextArea + JSInjections[provider].swapLanguages);
}

export function changeLanguage1(provider: AppSettings['provider'], translateWindow: BrowserWindow) {
  executeJavaScript(translateWindow, JSInjections[provider].changeLanguage1);
}

export function changeLanguage2(provider: AppSettings['provider'], translateWindow: BrowserWindow) {
  executeJavaScript(translateWindow, JSInjections[provider].changeLanguage2);
}

export function initTranslateWindow(provider: AppSettings['provider'], menuBar: Menubar): BrowserWindow {
  if (!menuBar.window) {
    throw new Error('Menubar BrowserWindow not found!');
  }

  const translateWidth = appConfig.width - appConfig.margin * 2;
  const translateHeight = appConfig.height - appConfig.headerHeight - appConfig.margin * 2;

  const translateWindow = new BrowserWindow({
    show: false,
    skipTaskbar: true,
    parent: menuBar.window,
    height: translateHeight,
    width: translateWidth,
    paintWhenInitiallyHidden: false,
    x: menuBar.window.getPosition()[0] + appConfig.margin,
    y: menuBar.window.getPosition()[1] + appConfig.headerHeight + appConfig.margin,
    frame: false,
    resizable: isDev(),
    movable: false,
    fullscreenable: false,
    hasShadow: false,
    minimizable: false,
    webPreferences: {
      devTools: isDev(),
    },
    alwaysOnTop: true,
  });

  translateWindow.loadURL('https://translate.google.com/').catch((e) => {
    throw e; // TODO
  });

  translateWindow.on('ready-to-show', () => {
    translateWindow.webContents
      .insertCSS(
        CSSInjections({
          darkmode: false,
        }),
      )
      .catch((e) => {
        console.error(e);
      });
  });

  translateWindow.on('show', () => {
    if (menuBar.window) {
      translateWindow.setPosition(
        menuBar.window.getPosition()[0] + appConfig.margin,
        menuBar.window.getPosition()[1] + appConfig.headerHeight + appConfig.margin,
      );
    }

    translateWindow.webContents.focus();
    translateWindow.webContents.executeJavaScript(JSInjections[provider].focusTextArea).catch((e) => {
      console.error(e);
    });
  });

  translateWindow.on('blur', () => {
    if (!menuBar.window) return;
    if (!menuBar.window.isFocused()) {
      translateWindow.hide();
      menuBar.hideWindow();
    }
  });

  return translateWindow;
}
