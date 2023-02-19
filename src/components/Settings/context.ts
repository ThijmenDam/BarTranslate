import { createContext, Dispatch, useContext, useCallback } from 'react';
import { AppSettings } from '../../../electron/types';

const SettingsContext = createContext<AppSettings | null>(null);
const SetSettingsContext = createContext<Dispatch<AppSettings> | null>(null);

function useSettingsContext() {
  const settings = useContext(SettingsContext);
  const setSettings = useContext(SetSettingsContext);

  const storeSettings = useCallback(
    (settingsToStore: AppSettings) => {
      if (!setSettings) return;

      // TODO: write to file
      console.info('should write to file ');
      setSettings({ ...settingsToStore });
    },
    [setSettings],
  );

  if (!settings || !setSettings) {
    throw new Error('Problem loading settings.');
  }

  return { settings, storeSettings };
}

export { SettingsContext, SetSettingsContext, useSettingsContext };
