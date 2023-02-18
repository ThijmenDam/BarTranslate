import { EmojiStyle } from '../styles';
import { SponsorBannerStyle } from './styles';

export function SponsorBanner() {
  return (
    <SponsorBannerStyle
      onClick={() => {
        window.Main.sponsor();
      }}
    >
      <button type="button">Sponsor This Project</button>
      <EmojiStyle>😃️</EmojiStyle>
    </SponsorBannerStyle>
  );
}
