import { AppSettings } from '../../../../../electron/types';
import { BindingStyle } from './styles';

interface BindingProps {
  type: 'key' | 'modifier'
  setting: keyof AppSettings['keyBindings']
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export default function Binding(props: BindingProps): JSX.Element {
  return (
    <BindingStyle>
      <select>
        <option>{props.type}</option>
      </select>
    </BindingStyle>
  );
}
