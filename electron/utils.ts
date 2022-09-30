import { Menubar } from 'menubar';

export function isDev() {
  const { NODE_ENV } = process.env;

  if (NODE_ENV !== 'production' && NODE_ENV !== 'development') {
    throw new Error(`Invalid NODE_ENV: ${NODE_ENV}`);
  }

  return NODE_ENV === 'development';
}

export function stringifyWithIndent(object: any) {
  return JSON.stringify(object, null, 2);
}

export function log(object: any) {
  if (isDev()) {
    console.info(object);
  }
}

export function toggleAppVisibility(menubar: Menubar) {
  if (!menubar.window?.isVisible()) {
    menubar.showWindow();
  } else {
    menubar.hideWindow();
  }
}

export function validateMenubar(menubar: Menubar) {
  if (!menubar.window) {
    throw new Error('Menubar BrowserWindow not properly initialized');
  }
}
