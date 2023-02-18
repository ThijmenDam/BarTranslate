import { css } from 'styled-components';

export const CSSDeepL = css`
  body {
    overflow-x: hidden !important;
  }

  header,
  aside,
  #dl_career_container,
  .dl_visible_desktop_only,
  .dl_cookieBanner,
  .dl_ad_pro_container,
  .lmt__docTrans-tab-container,
  .dl_visible_handheld_only,
  .dl_footerV2_container,
  .lmt__glossary_button,
  .lmt__formalitySwitch {
    display: none !important;
  }

  main#dl_translator {
    padding: 14px !important;
  }

  .dl_translator_page_container {
    max-width: calc(100vw);
  }

  section.lmt__side_container {
    min-width: 100%;
    box-shadow: 0 1px 4px 0 rgb(0 0 0 / 10%);
    border-radius: 8px;
    border: 1px solid #dae1e8;
  }

  .lmt__sides_wrapper {
    flex-direction: column;
  }

  .lmt__textarea_container {
    min-height: 10px !important;
    border-bottom-left-radius: 8px !important;
    border-bottom-right-radius: 8px !important;
  }

  .lmt--web .lmt__sides_container {
    border-width: 0 !important;
    border-radius: 0 !important;
    box-shadow: none !important;
    background-color: transparent !important;
  }

  .lmt__language_container {
    border-top-right-radius: 8px !important;
    border-top-left-radius: 8px !important;
  }

  .lmt__side_container--source {
    margin-bottom: 1rem;
  }

  #dictionary-section {
    margin-top: 1rem !important;
    margin-bottom: 0 !important;
  }

  /* TODO: PROPERLY POSITION SWITCHER */
  button.lmt__language_container_switch,
  button.lmt__language_container_switch.switched {
    display: none !important;
  }
`;
