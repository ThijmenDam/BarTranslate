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
    debug(`[ipcRenderer] showSettings ${show}`);
    ipcRenderer.send('showSettings', show);
  },

  writeSettingsToFile: (settings: AppSettings) => {
    debug(`[ipcRenderer] writeSettingsToFile`);
    debug({ settings });
    ipcRenderer.send('writeSettingsToFile', settings);
  },

  requestSettings: () => {
    debug(`[ipcRenderer] requestSettings`);
    ipcRenderer.send('requestSettings');
  },

  sponsor: () => {
    debug(`[ipcRenderer] sponsor`);
    ipcRenderer.send('sponsor');
  },

  providerChanged: (provider: Provider) => {
    debug(`[ipcRenderer] providerChanged ${provider}`);
    ipcRenderer.send('providerChanged', provider);
  },

  /**
   * Provides an easier way to listen to events
   */

  on: (channel: string, callback: Function) => {
    ipcRenderer.removeAllListeners(channel);
    ipcRenderer.on(channel, (_, data) => callback(data));
  },
};

contextBridge.exposeInMainWorld('Main', api);
