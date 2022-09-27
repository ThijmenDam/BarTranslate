import { FormEvent } from 'react';
import { AppSettings, Modifier, Key } from '../../../../../electron/types';
import { modifiers, keys } from './keycodes';
import { BindingStyle } from './styles';

interface BindingProps {
  type: 'key' | 'modifier'
  setting: keyof AppSettings['keyBindings']
  initialValue: Modifier | Key
}

export default function Binding(props: BindingProps): JSX.Element {
  const keycodes = props.type === 'key' ? keys : modifiers;

  function onInput(event: FormEvent<HTMLSelectElement>) {
    // TODO: change setting here
    const settingValue = (event.target as HTMLOptionElement).value;
    console.log(props.setting, settingValue);
  }

  return (
    <BindingStyle>
      <select value={props.initialValue} onInput={onInput}>
        {keycodes.map((k) => <option key={k[1]} value={k[1]}>{k[0]}</option>)}
      </select>
    </BindingStyle>
  );
}
