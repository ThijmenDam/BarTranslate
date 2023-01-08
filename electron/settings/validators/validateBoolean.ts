import { AppSettings } from '../../types';
import { defaultSettings } from '../default';

export function validateBoolean(
  appSettings: AppSettings,
  property: keyof Pick<AppSettings, 'autoscroll' | 'darkmode'>,
): AppSettings {
  const settings = { ...appSettings };

  if (!(property in appSettings) || !(settings[property] === true || settings[property] === false)) {
    settings[property] = defaultSettings[property];
  }

  return settings;
}
