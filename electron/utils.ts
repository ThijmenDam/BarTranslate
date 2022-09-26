// eslint-disable-next-line import/no-extraneous-dependencies
import { Event, Input, BrowserWindow } from 'electron';
import { Menubar } from 'menubar';
import { JSInjections } from './injections';

export const isDev = process.env.NODE_ENV === 'development';

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
  if (input.type === 'keyUp' && input.alt && input.code === 'KeyL') {
    if (translateWindow.isVisible()) {
      translateWindow.webContents.executeJavaScript(JSInjections.clearTextArea + JSInjections.swapLanguages)
        .catch((e) => { console.error(e); });
    }
  }

  // change language 1
  if (input.type === 'keyUp' && input.alt && input.code === 'KeyN') {
    if (translateWindow.isVisible()) {
      translateWindow.webContents.executeJavaScript(JSInjections.changeLanguage1)
        .catch((e) => { console.error(e); });
    }
  }

  // change language 2
  if (input.type === 'keyUp' && input.alt && input.code === 'KeyM') {
    if (translateWindow.isVisible()) {
      translateWindow.webContents.executeJavaScript(JSInjections.changeLanguage2)
        .catch((e) => { console.error(e); });
    }
  }
}
