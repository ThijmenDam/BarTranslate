// eslint-disable-next-line import/no-extraneous-dependencies
import { contextBridge, ipcRenderer } from 'electron';
import { AppSettings } from './types';

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

  showSettings: (show: boolean) => {
    ipcRenderer.send('showSettings', show);
  },

  setSettings: (settings: AppSettings) => {
    ipcRenderer.send('writeSettingsToFile', settings);
  },

  requestSettings: () => {
    ipcRenderer.send('requestSettings');
  },

  sponsor: () => {
    ipcRenderer.send('sponsor');
  },

  /**
   * Provide an easier way to listen to events
   */

  on: (channel: string, callback: Function) => {
    ipcRenderer.removeAllListeners(channel);
    ipcRenderer.on(channel, (_, data) => callback(data));
  },
};

contextBridge.exposeInMainWorld('Main', api);
