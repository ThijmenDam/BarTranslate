import settings from 'electron-settings';
import { AppSettings } from '../types';
import { debug } from '../utils';
import { defaultSettings } from './default';
import { validateSettings } from './validators/validateSettings';

export async function fetchAppSettingsFromFile(): Promise<AppSettings> {
  const settingsFromFile = (await settings.get('appSettings')) as AppSettings | null;

  if (!settingsFromFile) {
    debug('Found no settings file, returning default settings.');
    return defaultSettings;
  }

  debug({ settingsFromFile });

  return validateSettings(settingsFromFile);
}

export async function writeAppSettingsToFile(appSettingsToFile: AppSettings) {
  debug('Writing settings to file.');
  debug({ appSettingsToFile });

  // 'electron-settings' does not export types for proper casting?
  // eslint-disable-next-line
  await settings.set('appSettings', appSettingsToFile as any);
}
