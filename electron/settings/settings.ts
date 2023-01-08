import settings from 'electron-settings';
import { AppSettings } from '../types';
import { isDev } from '../utils';
import { validateSettings } from './validators/validateSettings';
import { defaultSettings } from './default';

export async function fetchAppSettingsFromFile(): Promise<AppSettings> {
  const settingsFromFile = (await settings.get('appSettings')) as AppSettings | null;

  if (isDev()) {
    console.info('Fetching settings from file');
    // console.info(stringifyWithIndent(settingsFromFile));
  }

  if (!settingsFromFile) {
    return defaultSettings;
  }

  return validateSettings(settingsFromFile);
}

export async function writeAppSettingsToFile(appSettingsToFile: AppSettings) {
  if (isDev()) {
    console.info('Writing settings to file');
    // console.info(stringifyWithIndent(appSettingsToFile));
  }

  await settings.set('appSettings', appSettingsToFile as any);
}
