import { AppSettings } from '../../../../../electron/types';
import { useSettingsContext } from '../../Settings';
import Binding from './Binding';
import { KeySelectStyle } from './styles';

interface KeySelectProps {
  setting: keyof AppSettings['keyBindings']
}

export default function Bindings({ setting }: KeySelectProps): JSX.Element {
  const { settings } = useSettingsContext();

  return (
    <KeySelectStyle>

      <Binding
        type="modifier"
        setting={setting}
        initialValue={settings.keyBindings[setting].modifier}
      />

      <Binding
        type="key"
        setting={setting}
        initialValue={settings.keyBindings[setting].key}
      />
    </KeySelectStyle>
  );
}
