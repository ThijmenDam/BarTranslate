import { Dispatch } from 'react';
import { AppSettings } from '../../../electron/types';
import Toggle from '../Toggle';

import {
  SettingsStyle, ContainerStyle, SponsorStyle, EmojiStyle, SettingsGroupTitleStyle, SettingsGroupStyle,
} from './styles';

interface SettingsProps {
  appSettings: AppSettings
  setAppSettings: Dispatch<AppSettings>
}

export default function Settings(props: SettingsProps) {
  return (
    <SettingsStyle>
      <ContainerStyle>

        <SettingsGroupTitleStyle>
          Settings
        </SettingsGroupTitleStyle>

        <SettingsGroupStyle>

          <Toggle
            setting="darkmode"
            label="Use system darkmode"
            checked={false}
            appSettings={props.appSettings}
            setAppSettings={props.setAppSettings}
            disabled
            divider
          />

          <Toggle
            setting="autoscroll"
            label="Scroll translate view to top when shown"
            checked={props.appSettings?.autoscroll || false}
            appSettings={props.appSettings}
            setAppSettings={props.setAppSettings}
          />

        </SettingsGroupStyle>

        <SettingsGroupTitleStyle>
          Key Bindings
        </SettingsGroupTitleStyle>

        <SettingsGroupStyle />

      </ContainerStyle>

      <SponsorStyle onClick={() => { window.Main.sponsor(); }}>
        <button type="button">
          Please consider buying me a coffee
        </button>
        <EmojiStyle>
          😊
        </EmojiStyle>
      </SponsorStyle>
    </SettingsStyle>
  );
}
