// eslint-disable-next-line import/no-extraneous-dependencies
import { Event, Input, BrowserWindow } from 'electron';
import { Menubar } from 'menubar';
import { changeLanguage1, swapLanguages, changeLanguage2 } from './translate-window';

export function validateWebContentsInputEvent(
  event: Event,
  input: Input,
  menuBar: Menubar,
  translateWindow: BrowserWindow,
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

  // Swap languages
  if (input.alt && input.code === 'KeyL') {
    event.preventDefault();
    swapLanguages(translateWindow);
  }

  // change language 1
  if (input.alt && input.code === 'KeyN') {
    event.preventDefault();
    changeLanguage1(translateWindow);
  }

  // change language 2
  if (input.alt && input.code === 'KeyM') {
    event.preventDefault();
    changeLanguage2(translateWindow);
  }
}
