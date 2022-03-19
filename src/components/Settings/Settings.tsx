import {
  SettingsStyle, ContainerStyle, SponsorStyle, EmojiStyle,
} from './styles';

export default function Settings() {
  return (
    <SettingsStyle>
      <ContainerStyle>
        <p>More features coming soon!</p>
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
