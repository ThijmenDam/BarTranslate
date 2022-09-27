// eslint-disable-next-line import/no-extraneous-dependencies
import { Event, Input, BrowserWindow } from 'electron';
import { Menubar } from 'menubar';
import { changeLanguage1, swapLanguages, changeLanguage2 } from './translate-window';
import { AppSettings } from './types';

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

  // Open settings
  if ((input.control || input.meta) && input.code === 'Comma') {
    menuBar.window.webContents.send('showSettings');
  }

  // TODO: use keys as configured in AppSettings
  // console.log(input);
  // console.log(keyBindings.switchLanguages.modifier);
  // console.log(keyBindings.switchLanguages.key);

  // Switch languages
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
