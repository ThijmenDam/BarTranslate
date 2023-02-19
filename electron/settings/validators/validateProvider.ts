import { AppSettings } from '../../types';
import { defaultSettings } from '../default';

export function validateProvider(appSettings: AppSettings): AppSettings {
  const property = 'provider';
  const settings = { ...appSettings };

  if (!(settings[property] === 'Google' || settings.provider === 'DeepL')) {
    settings[property] = defaultSettings[property];
  }

  return settings;
}
