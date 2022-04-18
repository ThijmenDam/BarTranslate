// eslint-disable-next-line import/no-extraneous-dependencies
import { Event, Input } from 'electron';
import { Menubar } from 'menubar';

export const isDev = process.env.NODE_ENV === 'development';

export function validateWebContentsInputEvent(event: Event, input: Input, menuBar: Menubar) {
  if (!menuBar.window) {
    throw new Error('Could not validate WebContents input event: MenuBar is not defined.');
  }

  // TODO: make configurable via settings
  if ((input.control || input.meta) && input.key === ',') {
    menuBar.window.webContents.send('showSettings');
  }
}
