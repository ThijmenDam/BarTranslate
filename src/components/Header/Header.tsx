import { faPowerOff, faCog, faAnglesLeft } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import {
  HeaderStyle, IconsContainerStyle, TitleStyle, IconStyle,
} from './styles';

interface HeaderProps {
  toggleSettings: () => void
  showSettings: boolean
}

export default function Header(props: HeaderProps) {
  return (
    <HeaderStyle>

      <TitleStyle>BarTranslate</TitleStyle>

      <IconsContainerStyle>
        <IconStyle onClick={() => { window.Main.shutDown(); }}>
          <FontAwesomeIcon icon={faPowerOff} />
        </IconStyle>
        <IconStyle onClick={props.toggleSettings}>
          <FontAwesomeIcon icon={props.showSettings ? faAnglesLeft : faCog} />
        </IconStyle>
      </IconsContainerStyle>

    </HeaderStyle>
  );
}
