import { AppSettings } from '../../../../electron/types';
import { Bindings } from './Bindings';
import { KeyBindingStyle, KeyBindingRow } from './styles';

interface KeyBindingProps {
  label: string;
  divider?: true;
  setting: keyof AppSettings['keyBindings'];
}

export function KeyBindSetting({ divider, label, setting }: KeyBindingProps): JSX.Element {
  return (
    <KeyBindingStyle>
      <KeyBindingRow>
        <span>{label}</span>
        <Bindings setting={setting} />
      </KeyBindingRow>

      {divider && <hr />}
    </KeyBindingStyle>
  );
}
