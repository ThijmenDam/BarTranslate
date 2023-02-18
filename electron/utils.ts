import { Menubar } from 'menubar';

export function isDev() {
  const { NODE_ENV } = process.env;

  if (NODE_ENV !== 'production' && NODE_ENV !== 'development') {
    throw new Error(`Invalid NODE_ENV: ${NODE_ENV}`);
  }

  return NODE_ENV === 'development';
}

export function stringifyWithIndent(object: JSON) {
  return JSON.stringify(object, null, 2);
}

export function debug(object: unknown) {
  if (isDev()) {
    console.debug(object);
  }
}

export function toggleAppVisibility(menubar: Menubar) {
  if (!menubar.window?.isVisible()) {
    menubar.showWindow();
  } else {
    menubar.hideWindow();
  }
}

export function validateMenubarWindow(menubar: Menubar) {
  if (!menubar.window) {
    throw new Error('Menubar BrowserWindow not properly initialized');
  }

  return menubar.window;
}
