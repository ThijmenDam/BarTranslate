import { BooleanAppSetting } from '../../../electron/types';
import { useSettingsContext } from '../Settings/context';
import { ToggleStyle } from './styles';

interface ToggleProps {
  label: string;
  checked: boolean;
  setting: BooleanAppSetting;
  disabled?: boolean;
  divider?: true;
}

export function Toggle({ checked, disabled, divider, label, setting }: ToggleProps): JSX.Element {
  const id = `check-${setting}`;
  const { settings, setSettings } = useSettingsContext();

  function toggle(key: BooleanAppSetting, value: boolean) {
    const localSettings = { ...settings };
    localSettings[key] = value;
    setSettings(localSettings);
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
