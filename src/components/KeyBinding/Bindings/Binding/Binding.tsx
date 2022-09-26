import { AppSettings } from '../../../../../electron/types';
import { modifiers, keys } from './keycodes';
import { BindingStyle } from './styles';

interface BindingProps {
  type: 'key' | 'modifier'
  // eslint-disable-next-line react/no-unused-prop-types
  setting: keyof AppSettings['keyBindings']
}

export default function Binding(props: BindingProps): JSX.Element {
  const keycodes = props.type === 'key' ? keys : modifiers;

  return (
    <BindingStyle>
      <select>
        {keycodes.map((k) => <option value={k[1]}>{k[0]}</option>)}
      </select>
    </BindingStyle>
  );
}
