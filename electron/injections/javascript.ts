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
    focusTextArea: 'console.log(1);',
    swapLanguages: 'console.log(2);',
    changeLanguage1: 'console.log(3);',
    changeLanguage2: 'console.log(4);',
    clearTextArea: `console.log(5);`,
  },
};

export { JSInjections };
