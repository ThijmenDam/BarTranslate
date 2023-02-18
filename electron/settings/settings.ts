import settings from 'electron-settings';
import { AppSettings } from '../types';
import { isDev } from '../utils';
import { validateSettings } from './validators/validateSettings';
import { defaultSettings } from './default';

export async function fetchAppSettingsFromFile(): Promise<AppSettings> {
  const settingsFromFile = (await settings.get('appSettings')) as AppSettings | null;

  if (isDev()) {
    console.debug('Fetching settings from file');
    // console.info(stringifyWithIndent(settingsFromFile));
  }

  if (!settingsFromFile) {
    return defaultSettings;
  }

  // TODO: REMOVE FORCE OF DEEPL
  settingsFromFile.provider = 'DeepL';

  return validateSettings(settingsFromFile);
}

export async function writeAppSettingsToFile(appSettingsToFile: AppSettings) {
  if (isDev()) {
    console.info('Writing settings to file');
    // console.info(stringifyWithIndent(appSettingsToFile));
  }

  // 'electron-settings' does not export types for proper casting?
  // eslint-disable-next-line
  await settings.set('appSettings', appSettingsToFile as any);
}
