const JSInjections = {
  Google: {
    focusTextArea: 'document.querySelector("textarea").focus();',
    swapLanguages: 'document.getElementsByClassName("U2dVxe")[0].click();',
    changeLanguage1: 'document.querySelectorAll("[jsname=\'k0o5Tb\']")[0].click();',
    changeLanguage2: 'document.querySelectorAll("[jsname=\'SDXlTc\']")[0].click();',
    clearTextArea: `
      document.querySelector("textarea").value = "";
      document.querySelector("textarea").dispatchEvent(new Event("input", { bubbles: true }));
    `,
  },
  DeepL: {
    focusTextArea: 'document.querySelector(".lmt__textarea_container").focus();',
    swapLanguages: 'document.querySelector(".lmt__language_container_switch").click();',
    changeLanguage1: 'document.querySelector(\'button[dl-test="translator-source-lang-btn"]\').click();',
    changeLanguage2: 'document.querySelector(\'button[dl-test="translator-target-lang-btn"]\').click();',
    clearTextArea: `document.querySelector('button[dl-test="translator-source-clear-button"]').click();`,
  },
};

export { JSInjections };
