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
