import Toggle, { ToggleGroupStyle } from '../Toggle';

import {
  SettingsStyle, ContainerStyle, SponsorStyle, EmojiStyle,
} from './styles';

export default function Settings() {
  return (
    <SettingsStyle>
      <ContainerStyle>

        <ToggleGroupStyle>
          <Toggle id="darkmode" label="Use system darkmode" disabled divider />
          <Toggle id="scroll-top" label="Scroll translate view to top when shown" disabled />
        </ToggleGroupStyle>

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
