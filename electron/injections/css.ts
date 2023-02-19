import { Provider } from '../types';
import { CSSDeepL } from './css-deepl';
import { CSSGoogle } from './css-google';

export function CSSInjections(provider: Provider): string {
  if (provider === 'Google') {
    return CSSGoogle.toString();
  }

  if (provider === 'DeepL') {
    return CSSDeepL.toString();
  }

  throw new Error(`Provider '${provider}' is invalid.`);

  // Kept for later reference
  // return HideRedundantElementsCSS.concat(DarkModeCSS).join('');
}
