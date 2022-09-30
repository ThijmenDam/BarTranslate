// eslint-disable-next-line import/no-extraneous-dependencies
import { Event, Input, BrowserWindow } from 'electron';
import { Menubar } from 'menubar';
import { fetchAppSettingsFromFile } from './settings';
import { changeLanguage1, swapLanguages, changeLanguage2 } from './translate-window';
import { AppSettings } from './types';
import { isDev } from './utils';

export function validateWebContentsInputEvent(
  event: Event,
  input: Input,
  menuBar: Menubar,
  translateWindow: BrowserWindow,
  keyBindings: AppSettings['keyBindings'],
) {
  if (!menuBar.window) {
    throw new Error('Could not validate WebContents input event: MenuBar is not defined.');
  }

  if (!translateWindow) {
    throw new Error('Could not validate WebContents input event: TranslateWindow is not defined.');
  }

  // open settings
  if ((input.control || input.meta) && input.code === 'Comma') {
    menuBar.window.webContents.send('showSettings');
  }

  // switch languages
  if (
    keyBindings.switchLanguages.modifier
    && keyBindings.switchLanguages.key
    && input.modifiers.includes(keyBindings.switchLanguages.modifier)
    && input.code === keyBindings.switchLanguages.key
  ) {
    event.preventDefault();
    swapLanguages(translateWindow);
  }

  // change language 1
  if (
    keyBindings.changeLanguage1.modifier
    && keyBindings.changeLanguage1.key
    && input.modifiers.includes(keyBindings.changeLanguage1.modifier)
    && input.code === keyBindings.changeLanguage1.key
  ) {
    event.preventDefault();
    changeLanguage1(translateWindow);
  }

  // change language 2
  if (
    keyBindings.changeLanguage2.modifier
    && keyBindings.changeLanguage2.key
    && input.modifiers.includes(keyBindings.changeLanguage2.modifier)
    && input.code === keyBindings.changeLanguage2.key
  ) {
    event.preventDefault();
    changeLanguage2(translateWindow);
  }
}

export function applyGlobalKeyboardShortcuts() {

}

export function applyLocalKeyboardShortcuts(menuBar: Menubar, translateWindow: BrowserWindow) {
  if (isDev()) {
    console.info('Configuring local key listeners');
  }

  fetchAppSettingsFromFile()
    .then((settings: AppSettings) => {
      if (!menuBar.window) {
        throw new Error('Menubar BrowserWindow not properly initialized!');
      }

      // TODO: remove previous shortcuts!!
      menuBar.window.webContents.on('before-input-event', (event, input) => {
        validateWebContentsInputEvent(event, input, menuBar, translateWindow, settings.keyBindings);
      });
      // TODO: remove previous shortcuts!!
      translateWindow.webContents.on('before-input-event', (event, input) => {
        validateWebContentsInputEvent(event, input, menuBar, translateWindow, settings.keyBindings);
      });
    });
}
