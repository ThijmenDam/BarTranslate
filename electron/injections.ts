import { css } from 'styled-components';

const HideRedundantElementsCSS = css`
  .pGxpHc,                  /* Page header */
  .VjFXz,                   /* Space behind page header */
  .a88hkc,                  /* "Sent feedback" button */
  .FFpbKc,                  /* Microphone input, amount of words */
  .KIXMEf,                  /* Share button */
  .a8FIud,                  /* Favorite button */
  .nG3XIb,                  /* Rate translation button */
  nav {                     /* Buttons below translate input */
    display: none!important;
  }
  .OlSOob {                 /* Translate view. */
    position: absolute;
    width: 100%;
  }
`;

const DarkModeCSS = css`

`;

interface CSSOptions {
  darkmode: boolean
}

function CSSInjections(options: CSSOptions): string {
  if (options.darkmode) {
    return HideRedundantElementsCSS.concat(DarkModeCSS).join('');
  }
  return HideRedundantElementsCSS.toString();
}

export { CSSInjections };
