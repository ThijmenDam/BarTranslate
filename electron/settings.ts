import settings from 'electron-settings';
import { AppSettings } from './types';
import { isDev } from './utils';

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

// TODO: better validation
function validSettings(appSettings: AppSettings): boolean {
  const properties = ['autoscroll', 'darkmode', 'keyBindings'];

  for (const prop of properties) {
    if (!(prop in appSettings)) {
      return false;
    }
  }

  return true;
}

export async function fetchAppSettingsFromFile(): Promise<AppSettings> {
  const settingsFromFile = await settings.get('appSettings') as AppSettings | null;

  if (isDev()) {
    console.info('Fetching settings from file');
    // console.info(stringifyWithIndent(settingsFromFile));
  }

  if (settingsFromFile && validSettings(settingsFromFile)) {
    return settingsFromFile;
  }

  return defaultSettings;
}

export async function writeAppSettingsToFile(appSettingsToFile: AppSettings) {
  if (isDev()) {
    console.info('Writing settings to file');
    // console.info(stringifyWithIndent(appSettingsToFile));
  }

  await settings.set('appSettings', appSettingsToFile as any);
}
