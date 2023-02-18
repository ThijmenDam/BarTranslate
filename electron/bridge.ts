// eslint-disable-next-line import/no-extraneous-dependencies
import { contextBridge, ipcRenderer } from 'electron';
import { AppSettings } from './types';
import { debug } from './utils';

export const api = {
  /**
   * Frontend interface to interact with the main process.
   * The functions below can be accessed using `window.Main.myFunction`
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
   * Provides an easier way to listen to events
   */

  on: (channel: string, callback: Function) => {
    ipcRenderer.removeAllListeners(channel);
    ipcRenderer.on(channel, (_, data) => {
      debug(`[ipcRenderer] ${channel}`);
      callback(data);
    });
  },
};

contextBridge.exposeInMainWorld('Main', api);
