// eslint-disable-next-line import/no-extraneous-dependencies
import {
  Event, Input, BrowserWindow, globalShortcut,
} from 'electron';
import { Menubar } from 'menubar';
import { fetchAppSettingsFromFile } from './settings';
import { changeLanguage1, swapLanguages, changeLanguage2 } from './translate-window';
import { AppSettings } from './types';
import { isDev, toggleAppVisibility, validateMenubarWindow } from './utils';

function menubarWindowInputHandler(event: Event, input: Input, menubar: Menubar) {
  if (!menubar.window) {
    throw new Error('Could not validate WebContents input event: MenuBar is not defined.');
  }

  // open settings
  if ((input.control || input.meta) && input.code === 'Comma') {
    menubar.window.webContents.send('showSettings');
  }
}

function translateWindowInputHandler(
  event: Event,
  input: Input,
  menubar: Menubar,
  translateWindow: BrowserWindow,
  keyBindings: AppSettings['keyBindings'],
) {
  if (!menubar.window) {
    throw new Error('Could not validate WebContents input event: MenuBar is not defined.');
  }

  if (!translateWindow) {
    throw new Error('Could not validate WebContents input event: TranslateWindow is not defined.');
  }

  // open settings
  if ((input.control || input.meta) && input.code === 'Comma') {
    menubar.window.webContents.send('showSettings');
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

async function registerGlobalKeyboardShortcuts(menuBar: Menubar) {
  console.info('Registering local key listeners');
  globalShortcut.unregisterAll();
  // TODO: use shortcut as configured in settings
  globalShortcut.register('alt+k', () => { toggleAppVisibility(menuBar); });
}

async function registerLocalKeyboardShortcuts(menubar: Menubar, translateWindow: BrowserWindow) {
  if (isDev()) {
    console.info('Registering local key listeners');
  }

  const menubarWindow = validateMenubarWindow(menubar);
  const settings = await fetchAppSettingsFromFile();

  function translateWindowListener(event: Event, input: Input) {
    translateWindowInputHandler(event, input, menubar, translateWindow, settings.keyBindings);
  }

  function menubarWindowListener(event: Event, input: Input) {
    menubarWindowInputHandler(event, input, menubar);
  }

  translateWindow.webContents.removeAllListeners('before-input-event');
  translateWindow.webContents.on('before-input-event', translateWindowListener);

  menubarWindow.webContents.removeAllListeners('before-input-event');
  menubarWindow.webContents.on('before-input-event', menubarWindowListener);
}

export async function registerKeyboardShortcuts(menuBar: Menubar, translateWindow: BrowserWindow) {
  await registerGlobalKeyboardShortcuts(menuBar);
  await registerLocalKeyboardShortcuts(menuBar, translateWindow);
}
