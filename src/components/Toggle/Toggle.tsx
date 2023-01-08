import { AppSettingsBooleans } from '../../../electron/types';
import { useSettingsContext } from '../Settings/Settings';
import { ToggleStyle } from './styles';

interface ToggleProps {
  label: string;
  checked: boolean;
  setting: AppSettingsBooleans;
  disabled?: boolean;
  divider?: true;
}

export default function Toggle(props: ToggleProps): JSX.Element {
  const id = `check-${props.setting}`;
  const { settings, setSettings } = useSettingsContext();

  function toggle(setting: AppSettingsBooleans, value: boolean) {
    const localSettings = { ...settings };
    localSettings[setting] = value;
    setSettings(localSettings);
  }

  return (
    <ToggleStyle>
      <input
        type="checkbox"
        id={id}
        className="toggle"
        disabled={props.disabled}
        checked={props.checked}
        onChange={(event) => {
          toggle(props.setting, event.target.checked);
        }}
      />

      <label htmlFor={id}>{props.label}</label>

      {props.divider && <hr />}
    </ToggleStyle>
  );
}
