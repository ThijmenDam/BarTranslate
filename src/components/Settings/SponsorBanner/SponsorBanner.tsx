import { EmojiStyle } from '../styles';
import { SponsorBannerStyle } from './styles';
import { SponsorBannerProps } from './types';

export function SponsorBanner({}: SponsorBannerProps) {
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
