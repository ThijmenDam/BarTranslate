// eslint-disable-next-line import/no-extraneous-dependencies
import { Event, Input } from 'electron';

export const isDev = process.env.NODE_ENV === 'development';

export function validateWebContentsInputEvent(event: Event, input: Input) {
  // if (menuBar?.window) {
  //   menuBar.window.webContents.send('ping');
  //   menuBar.window.webContents.send('ping');
  // }
  console.log('control', input.control, 'key', input.key);
}
