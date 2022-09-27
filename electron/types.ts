type Modifier = 'alt / option' | 'control' | 'meta'; // alt / control / meta
type Key = '';

// eslint-disable-next-line @typescript-eslint/no-unused-vars
interface KeyBinding {
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
