export type Modifier = 'alt' | 'control' | 'meta' | 'shift';
export type Key = string; // TODO

export interface KeyBinding {
  modifier: Modifier | null;
  key: Key | null;
}

export interface AppConfig {
  width: number;
  height: number;
  margin: number;
  headerHeight: number;
}

export type Provider = 'Google' | 'DeepL';

export interface AppSettings {
  provider: Provider;
  autoscroll: boolean;
  darkmode: boolean;
  keyBindings: {
    toggleApp: KeyBinding;
    switchLanguages: KeyBinding;
    changeLanguage1: KeyBinding;
    changeLanguage2: KeyBinding;
  };
}

export type BooleanAppSetting = 'autoscroll' | 'darkmode';
