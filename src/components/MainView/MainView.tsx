import { useState, useEffect } from 'react';
import { AppSettings } from '../../../electron/types';
import Header from '../Header';
import Settings from '../Settings';

import Translate from '../Translate';
import { MainViewStyle } from './styles';

export default function MainView() {
  const [appSettings, setAppSettings] = useState<AppSettings | null>(null);
  const [showSettings, setShowSettings] = useState<boolean>(false);

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

    window.Main.on('setSettings', (settingsFromMain: AppSettings) => {
      setAppSettings(settingsFromMain);
    });
  }, []);

  useEffect(() => {
    if (!appSettings) return;
    window.Main.setSettings(appSettings);
  }, [appSettings]);

  return (
    <MainViewStyle>
      <Header
        toggleSettings={() => { toggleSettings(); }}
        showSettings={showSettings}
      />
      {showSettings
       && showSettings
        ? <Settings appSettings={appSettings} setAppSettings={setAppSettings} />
        : <Translate />}
    </MainViewStyle>
  );
}
