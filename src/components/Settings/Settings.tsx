import { Dispatch } from 'react';
import { SettingsContext, SetSettingsContext } from './context';
import { AppSettings } from '../../../electron/types';
import { KeyBindSetting } from './KeyBindSetting';
import { Toggle } from '../Toggle';

import {
  SettingsStyle,
  ContainerStyle,
  SponsorStyle,
  EmojiStyle,
  SettingsGroupTitleStyle,
  SettingsGroupStyle,
} from './styles';

interface SettingsProps {
  appSettings: AppSettings;
  setAppSettings: Dispatch<AppSettings>;
}

export function Settings({ appSettings, setAppSettings }: SettingsProps) {
  return (
    <SettingsContext.Provider value={appSettings}>
      <SetSettingsContext.Provider value={setAppSettings}>
        <SettingsStyle>
          <ContainerStyle>
            <SettingsGroupTitleStyle>Settings</SettingsGroupTitleStyle>

            <SettingsGroupStyle>
              <Toggle setting="darkmode" label="Use system darkmode" checked={false} disabled divider />

              <Toggle
                setting="autoscroll"
                label="Scroll translate view to top when shown"
                checked={appSettings?.autoscroll || false}
              />
            </SettingsGroupStyle>

            <SettingsGroupTitleStyle>Key Bindings</SettingsGroupTitleStyle>

            <SettingsGroupStyle>
              <KeyBindSetting label="Toggle app" setting="toggleApp" divider />

              <KeyBindSetting label="Switch languages" setting="switchLanguages" divider />

              <KeyBindSetting label="Change language 1" setting="changeLanguage1" divider />

              <KeyBindSetting label="Change language 2" setting="changeLanguage2" />
            </SettingsGroupStyle>
          </ContainerStyle>

          <SponsorStyle
            onClick={() => {
              window.Main.sponsor();
            }}
          >
            <button type="button">Please consider buying me a coffee</button>
            <EmojiStyle>😊</EmojiStyle>
          </SponsorStyle>
        </SettingsStyle>
      </SetSettingsContext.Provider>
    </SettingsContext.Provider>
  );
}
