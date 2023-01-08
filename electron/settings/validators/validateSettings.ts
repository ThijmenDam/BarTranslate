import { AppSettings } from '../../types';
import { validateBoolean } from './validateBoolean';
import { validateKeybindings } from './validateKeybindings';
import { validateProvider } from './validateProvider';

/**
 * Check if the application settings are properly configured. If not, resolve the issues.
 */
export function validateSettings(appSettings: AppSettings): AppSettings {
  let settings: AppSettings = { ...appSettings };

  settings = validateBoolean(settings, 'darkmode');
  settings = validateBoolean(settings, 'autoscroll');

  settings = validateProvider(settings);
  settings = validateKeybindings(settings);

  return settings;
}
