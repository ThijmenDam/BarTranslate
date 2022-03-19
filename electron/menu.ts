// eslint-disable-next-line import/no-extraneous-dependencies
import { Menu } from 'electron';

const template: any = [
  {
    label: 'BarTranslate',
    submenu: [
      { role: 'quit' },
    ],
  },
];

export default function setAppMenu() {
  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}
