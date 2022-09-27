export type Modifier = 'alt' | 'control' | 'meta';
export type Key = string; // TODO

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export interface KeyBinding {
  modifier: Modifier | null
  key: Key | null
}

export interface AppConfig {
  width: number
  height: number
  margin: number
  headerHeight: number
}

export interface AppSettings {
  autoscroll: boolean
  darkmode: boolean
  keyBindings: {
    toggleApp: KeyBinding
    switchLanguages: KeyBinding
    changeLanguage1: KeyBinding
    changeLanguage2: KeyBinding
  }
}
