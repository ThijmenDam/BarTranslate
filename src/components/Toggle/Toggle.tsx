// import { Dispatch } from 'react';
import { Dispatch } from 'react';
import { AppSettings } from '../../../electron/types';
// import { AppSettings } from '../../../electron/types';
import { ToggleStyle } from './styles';

interface ToggleProps {
  label: string
  checked: boolean
  setting: keyof AppSettings
  appSettings: AppSettings
  setAppSettings: Dispatch<AppSettings>
  disabled?: boolean
  divider?: boolean
}

export default function Toggle(props: ToggleProps): JSX.Element {
  const id = `check-${props.setting}`;

  function toggle(setting: keyof AppSettings, value: boolean) {
    const localSettings = { ...props.appSettings };
    localSettings[setting] = value;
    props.setAppSettings(localSettings);
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

      <label htmlFor={id}>
        {props.label}
      </label>

      {props.divider && <hr />}

    </ToggleStyle>
  );
}
