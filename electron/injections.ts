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

  /* Translate view at top */
  div[jsname="gnoFo"] {
    position: absolute;
    width: 100%;
  }
  
  /* Background color of translate view */
  .zQTmif {
    background: #f1f1f7!important;
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

const JSInjections = {
  focusTextArea: 'document.querySelector("textarea").focus();',
  swapLanguages: 'document.getElementsByClassName("U2dVxe")[0].click();',
  changeLanguage1: 'document.querySelectorAll("[jsname=\'k0o5Tb\']")[0].click();',
  changeLanguage2: 'document.querySelectorAll("[jsname=\'SDXlTc\']")[0].click();',
  clearTextArea: `
    document.querySelector("textarea").value = "";
    document.querySelector("textarea").dispatchEvent(new Event("input", { bubbles: true }));
  `,
};

export { CSSInjections, JSInjections };
