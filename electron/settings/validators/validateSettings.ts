import { AppSettings } from '../../types';
import { debug } from '../../utils';
import { validateBoolean } from './validateBoolean';
import { validateKeybindings } from './validateKeybindings';
import { validateProvider } from './validateProvider';

/**
 * Check if the application settings are properly configured. If not, resolve the issues.
 */
export function validateSettings(appSettings: AppSettings): AppSettings {
  debug('Validating settings');

  let validatedSettings: AppSettings = { ...appSettings };

  validatedSettings = validateBoolean(validatedSettings, 'darkmode');
  validatedSettings = validateBoolean(validatedSettings, 'autoscroll');

  validatedSettings = validateProvider(validatedSettings);
  validatedSettings = validateKeybindings(validatedSettings);

  debug({ validatedSettings });

  return validatedSettings;
}
