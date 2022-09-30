import settings from 'electron-settings';
import { AppSettings } from './types';

const defaultSettings: AppSettings = {
  autoscroll: false,
  darkmode: false,
  keyBindings: {
    toggleApp: {
      key: null,
      modifier: null,
    },
    switchLanguages: {
      key: null,
      modifier: null,
    },
    changeLanguage1: {
      key: null,
      modifier: null,
    },
    changeLanguage2: {
      key: null,
      modifier: null,
    },
  },
};

// eslint-disable-next-line @typescript-eslint/no-unused-vars
function validSettings(appSettings: AppSettings): boolean {
  // TODO: actual validation
  return true;
}

export async function fetchAppSettingsFromFile(): Promise<AppSettings> {
  const settingsFromFile = await settings.get('appSettings') as AppSettings | null;

  console.log('fetchAppSettingsFromFile');
  console.log({ settingsFromFile });

  if (settingsFromFile && validSettings(settingsFromFile)) {
    return settingsFromFile;
  }

  return defaultSettings;
}

export async function writeAppSettingsToFile(appSettings: AppSettings) {
  console.log('writeSettingsToFile');
  console.log({ appSettings });
  await settings.set('appSettings', appSettings as any);
}
