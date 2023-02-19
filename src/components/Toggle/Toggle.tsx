import { BooleanAppSetting, AppSettings, Provider } from '../../../electron/types';
import { useSettingsContext } from '../Settings/context';
import { ToggleStyle } from './styles';

interface ToggleProps {
  label: string;
  checked: boolean;
  setting: BooleanAppSetting | Provider;
  disabled?: boolean;
  divider?: true;
}

export function Toggle({ checked, disabled, divider, label, setting }: ToggleProps): JSX.Element {
  const id = `check-${setting}`;
  const { settings, setSettings } = useSettingsContext();

  function toggle(key: BooleanAppSetting | AppSettings['provider'], value: boolean) {
    const localSettings = { ...settings };

    if (key === 'Google' && value) {
      window.Main.providerChanged('Google');
      localSettings.provider = 'Google';
    }

    if (key === 'DeepL' && value) {
      window.Main.providerChanged('DeepL');
      localSettings.provider = 'DeepL';
    }

    if (key === 'autoscroll' || key === 'darkmode') {
      localSettings[key] = value;
    }

    window.Main.writeSettingsToFile({ ...localSettings });
    setSettings({ ...localSettings });
  }

  return (
    <ToggleStyle>
      <input
        type="checkbox"
        id={id}
        className="toggle"
        disabled={disabled}
        checked={checked}
        onChange={(event) => {
          toggle(setting, event.target.checked);
        }}
      />

      <label htmlFor={id}>{label}</label>

      {divider && <hr />}
    </ToggleStyle>
  );
}
