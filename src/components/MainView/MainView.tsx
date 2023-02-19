import { useState, useEffect } from 'react';
import { AppSettings } from '../../../electron/types';
import { Header } from '../Header';
import { Settings } from '../Settings';

import { Translate } from '../Translate';
import { MainViewStyle } from './styles';

let initialized = false;

export function MainView() {
  const [appSettings, setAppSettings] = useState<AppSettings | null>(null);
  const [showSettings, setShowSettings] = useState<boolean>(false);

  useEffect(() => {
    if (!initialized && !appSettings) {
      initialized = true;
      window.Main.requestSettings();
    }
  }, [appSettings]);

  function toggleSettings() {
    window.Main.showSettings(!showSettings);
    setShowSettings(!showSettings);
  }

  // Events triggered via 'menuBar.window.webContents.send('ABC');'
  useEffect(() => {
    window.Main.on('showSettings', () => {
      window.Main.showSettings(true);
      setShowSettings(true);
    });

    window.Main.on('passSettingsToRenderer', (settingsFromMain: AppSettings) => {
      setAppSettings({ ...settingsFromMain });
    });
  }, []);

  return (
    <MainViewStyle>
      <Header
        toggleSettings={() => {
          toggleSettings();
        }}
        showSettings={showSettings}
      />

      {showSettings && appSettings && <Settings appSettings={appSettings} setAppSettings={setAppSettings} />}

      {!showSettings && <Translate />}
    </MainViewStyle>
  );
}
