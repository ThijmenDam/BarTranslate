import { AppSettings } from '../../../electron/types';
import Bindings from './Bindings';
import { KeyBindingStyle, KeyBindingRow } from './styles';

interface KeyBindingProps {
  label: string
  // defaultLabel: string
  divider?: true
  setting: keyof AppSettings['keyBindings']
}

export default function KeyBinding(props: KeyBindingProps): JSX.Element {
  return (
    <KeyBindingStyle>

      <KeyBindingRow>
        <span>{props.label}</span>
        <Bindings setting={props.setting} />
      </KeyBindingRow>

      {props.divider && <hr />}
    </KeyBindingStyle>
  );
}
