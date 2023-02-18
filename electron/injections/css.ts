import { AppSettings } from '../types';
import { CSSDeepL } from './css-deepl';
import { CSSGoogle } from './css-google';

export function CSSInjections(settings: AppSettings): string {
  if (settings.provider === 'Google') {
    return CSSGoogle.toString();
  }

  if (settings.provider === 'DeepL') {
    return CSSDeepL.toString();
  }

  throw new Error(`Provider '${settings.provider}' is invalid.`);

  // Kept for later reference
  // return HideRedundantElementsCSS.concat(DarkModeCSS).join('');
}
