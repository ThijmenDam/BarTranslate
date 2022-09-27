import { Dispatch } from 'react';
import { AppSettings } from '../../../electron/types';
import KeyBinding from '../KeyBinding';
import Toggle from '../Toggle';

import {
  SettingsStyle, ContainerStyle, SponsorStyle, EmojiStyle, SettingsGroupTitleStyle, SettingsGroupStyle,
} from './styles';

interface SettingsProps {
  appSettings: AppSettings | null
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

          {props.appSettings && (
          <>
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
          </>
          )}

        </SettingsGroupStyle>

        <SettingsGroupTitleStyle>
          Key Bindings
        </SettingsGroupTitleStyle>

        <SettingsGroupStyle>

          <KeyBinding
            label="Toggle app"
            // defaultLabel="alt / option + K"
            setting="toggleApp"
            divider
          />

          <KeyBinding
            label="Switch languages"
            // defaultLabel="alt / option + L"
            setting="switchLanguages"
            divider
          />

          <KeyBinding
            label="Change language 1"
            // defaultLabel="alt / option + N"
            setting="changeLanguage1"
            divider
          />

          <KeyBinding
            label="Change language 2"
            // defaultLabel="alt / option + M"
            setting="changeLanguage2"
          />

        </SettingsGroupStyle>

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
