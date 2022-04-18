import { useState } from 'react';
import Header from '../Header';
import Settings from '../Settings';

import Translate from '../Translate';
import { MainViewStyle } from './styles';

export default function MainView() {
  const [showSettings, setShowSettings] = useState<boolean>(false);

  window.Main.on('showSettings', () => {
    window.Main.setSettings(true);
    setShowSettings(true);
  });

  function toggleSettings() {
    window.Main.setSettings(!showSettings);
    setShowSettings(!showSettings);
  }

  return (
    <MainViewStyle>
      <Header
        toggleSettings={() => { toggleSettings(); }}
        showSettings={showSettings}
      />
      {showSettings && showSettings ? <Settings /> : <Translate />}
    </MainViewStyle>
  );
}
