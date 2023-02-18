import { Dispatch } from 'react';
import { AppSettings } from '../../../electron/types';
import { Toggle } from '../Toggle';
import { SettingsContext, SetSettingsContext } from './context';
import { KeyBindSetting } from './KeyBindSetting';
import { SponsorBanner } from './SponsorBanner';

import { SettingsStyle, ContainerStyle, SettingsGroupTitleStyle, SettingsGroupStyle } from './styles';

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
            {/* Sponsor */}
            <SponsorBanner />

            {/* General */}
            <SettingsGroupTitleStyle>General</SettingsGroupTitleStyle>
            <SettingsGroupStyle>
              <Toggle setting="darkmode" label="Use system darkmode" checked={false} disabled divider />
              <Toggle
                setting="autoscroll"
                label="Scroll translate view to top when shown"
                checked={appSettings?.autoscroll || false}
              />
            </SettingsGroupStyle>

            {/* Translation Provider */}
            <SettingsGroupTitleStyle>Translation Provider</SettingsGroupTitleStyle>
            <SettingsGroupStyle>
              <Toggle setting="Google" label="Google" checked={appSettings?.provider === 'Google'} divider />
              <Toggle setting="DeepL" label="DeepL" checked={appSettings?.provider === 'DeepL'} />
            </SettingsGroupStyle>

            {/* Key Bindings */}
            <SettingsGroupTitleStyle>Key Bindings</SettingsGroupTitleStyle>
            <SettingsGroupStyle>
              <KeyBindSetting label="Toggle app" setting="toggleApp" divider />
              <KeyBindSetting label="Switch languages" setting="switchLanguages" divider />
              <KeyBindSetting label="Change language 1" setting="changeLanguage1" divider />
              <KeyBindSetting label="Change language 2" setting="changeLanguage2" />
            </SettingsGroupStyle>
          </ContainerStyle>
        </SettingsStyle>
      </SetSettingsContext.Provider>
    </SettingsContext.Provider>
  );
}
