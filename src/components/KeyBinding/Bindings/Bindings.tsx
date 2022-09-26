import { AppSettings } from '../../../../electron/types';
import Binding from './Binding';
import { KeySelectStyle } from './styles';

interface KeySelectProps {
  setting: keyof AppSettings['keyBindings']
}

export default function Bindings(props: KeySelectProps): JSX.Element {
  return (
    <KeySelectStyle>
      <Binding type="modifier" setting={props.setting} />
      <Binding type="key" setting={props.setting} />
    </KeySelectStyle>
  );
}
