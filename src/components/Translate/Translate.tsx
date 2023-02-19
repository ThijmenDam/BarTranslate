import { TranslateStyle } from './styles';

/**
 * This view is only visible when the BrowserWindow overlay is not constructed yet, hence the loading animation.
 */
export function Translate() {
  return <TranslateStyle />;
}
