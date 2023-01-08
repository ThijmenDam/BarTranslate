import { AppSettings } from '../../types';
import { defaultSettings } from '../default';

export function validateKeybindings(appSettings: AppSettings): AppSettings {
  const property = 'keyBindings';
  const settings = { ...appSettings };

  if (!settings[property]) {
    settings[property] = defaultSettings[property];
  }

  const requiredSubProperties: Array<keyof AppSettings['keyBindings']> = [
    'toggleApp',
    'switchLanguages',
    'changeLanguage1',
    'changeLanguage2',
  ];

  for (const subProperty of requiredSubProperties) {
    const value = settings[property][subProperty];

    if (!value || !value.key || !value.modifier) {
      settings[property] = defaultSettings[property];
    }
  }

  return settings;
}
