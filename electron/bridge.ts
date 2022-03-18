// eslint-disable-next-line import/no-extraneous-dependencies
import { contextBridge, ipcRenderer } from 'electron';

export const api = {
  /**
   * Here you can expose functions to the renderer process
   * so they can interact with the main (electron) side
   * without security problems.
   *
   * The functions below can accessed using `window.Main.myFunction`
   */

  sendMessage: (message: string) => {
    ipcRenderer.send('message', message);
  },

  shutDown: () => {
    ipcRenderer.send('shutdown');
  },

  setSettings: (settings: boolean) => {
    ipcRenderer.send('setSettings', settings);
  },

  sponsor: () => {
    ipcRenderer.send('sponsor');
  },

  /**
   * Provide an easier way to listen to events
   */
  on: (channel: string, callback: Function) => {
    ipcRenderer.on(channel, (_, data) => callback(data));
  },
};

contextBridge.exposeInMainWorld('Main', api);
