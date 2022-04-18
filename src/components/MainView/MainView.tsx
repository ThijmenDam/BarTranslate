import { useState } from 'react';
import Header from '../Header';
import Settings from '../Settings';

import Translate from '../Translate';
import { MainViewStyle } from './styles';

export default function MainView() {
  const [showSettings, setShowSettings] = useState<boolean>(false);

  // TODO
  window.Main.on('ping', () => {
    console.log('pong');
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
