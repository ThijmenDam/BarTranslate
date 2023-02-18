import { FormEvent } from 'react';
import { AppSettings, Modifier, Key } from '../../../../../../electron/types';
import { useSettingsContext } from '../../../context';
import { modifiers, keys } from './keycodes';
import { BindingStyle } from './styles';

interface BindingProps {
  type: 'key' | 'modifier';
  setting: keyof AppSettings['keyBindings'];
  initialValue: Modifier | Key | null;
}

export function Binding({ initialValue, setting, type }: BindingProps): JSX.Element {
  const { settings, setSettings } = useSettingsContext();
  const keycodes = type === 'key' ? keys : modifiers;

  // Store changed binding in settings
  function onInput(event: FormEvent<HTMLSelectElement>) {
    const newSettings = { ...settings };
    const settingValue = (event.target as HTMLOptionElement).value;

    if (!settingValue) return;

    if (type === 'key') {
      newSettings.keyBindings[setting][type] = settingValue as Key;
    }

    if (type === 'modifier') {
      newSettings.keyBindings[setting][type] = settingValue as Modifier;
    }

    setSettings({ ...newSettings });
  }

  return (
    <BindingStyle>
      <select value={initialValue || undefined} onInput={onInput} className={type}>
        <option key={undefined} value={undefined}>
          {`No ${type === 'key' ? 'Key' : 'Modifier'}`}
        </option>

        {keycodes.map((k) => (
          <option key={k[1]} value={k[1]}>
            {k[0]}
          </option>
        ))}
      </select>
    </BindingStyle>
  );
}
