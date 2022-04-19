import settings from 'electron-settings';
import { AppSettings } from './types';

export async function fetchAppSettingsFromFile(): Promise<AppSettings> {
  const settingsFromFile = await settings.get('appSettings');

  // Default
  if (!settingsFromFile) {
    return { autoscroll: false, darkmode: false };
  }

  // From file -- TODO: add validation of file settings
  const autoscroll = await settings.get('appSettings.autoscroll') as boolean;
  const darkmode = await settings.get('appSettings.darkmode') as boolean;

  return { autoscroll, darkmode };
}

export async function writeAppSettingsToFile(appSettings: AppSettings) {
  await settings.set('appSettings', appSettings as any);
}
