// eslint-disable-next-line import/no-extraneous-dependencies
import { contextBridge, ipcRenderer } from 'electron';
import { AppSettings, Provider } from './types';
import { debug } from './utils';

export const api = {
  /**
   * Frontend interface to interact with the main process.
   * The functions below can be accessed using `window.Main.myFunction`
   */

  shutDown: () => {
    ipcRenderer.send('shutdown');
  },

  showSettings: (show: boolean) => {
    ipcRenderer.send('showSettings', show);
  },

  writeSettingsToFile: (settings: AppSettings) => {
    ipcRenderer.send('writeSettingsToFile', settings);
  },

  requestSettings: () => {
    ipcRenderer.send('requestSettings');
  },

  sponsor: () => {
    ipcRenderer.send('sponsor');
  },

  providerChanged: (provider: Provider) => {
    ipcRenderer.send('providerChanged', provider);
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
