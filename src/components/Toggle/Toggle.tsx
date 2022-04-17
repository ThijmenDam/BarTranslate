import { ToggleStyle } from './styles';

interface ToggleProps {
  id: string
  label: string
  disabled?: boolean
  divider?: boolean
}

export default function Toggle(props: ToggleProps): JSX.Element {
  const id = `check-${props.id}`;

  return (
    <ToggleStyle>
      <input type="checkbox" id={id} className="toggle" disabled={props.disabled} />
      <label htmlFor={id}>{props.label}</label>
      {props.divider && <hr />}
    </ToggleStyle>
  );
}
