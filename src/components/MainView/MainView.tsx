import { useState, useEffect } from 'react';
import Header from '../Header';
import Settings from '../Settings';

import Translate from '../Translate';
import { MainViewStyle } from './styles';

export default function MainView() {
  const [showSettings, setShowSettings] = useState<boolean>(false);

  function toggleSettings() {
    window.Main.setSettings(!showSettings);
    setShowSettings(!showSettings);
  }

  useEffect(() => {

  }, [showSettings]);

  return (
    <MainViewStyle>
      <Header toggleSettings={() => { toggleSettings(); }} />
      {showSettings && showSettings ? <Settings /> : <Translate />}
    </MainViewStyle>
  );
}
