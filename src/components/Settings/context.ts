import { createContext, Dispatch, useContext } from 'react';
import { AppSettings } from '../../../electron/types';

const SettingsContext = createContext<AppSettings | null>(null);
const SetSettingsContext = createContext<Dispatch<AppSettings> | null>(null);

function useSettingsContext() {
  const settings = useContext(SettingsContext);
  const setSettings = useContext(SetSettingsContext);

  if (!settings || !setSettings) {
    throw new Error('Problem loading settings.');
  }
  return { settings, setSettings };
}

export { SettingsContext, SetSettingsContext, useSettingsContext };
