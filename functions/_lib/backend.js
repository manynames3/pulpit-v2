const DEFAULT_BACKEND_TIMEOUT_MS = 60000;

export function requireBackendOrigin(env) {
  const origin = env.PULPIT_V2_API_ORIGIN;
  if (!origin) {
    throw new Error("Missing PULPIT_V2_API_ORIGIN Pages environment variable.");
  }
  return origin.replace(/\/+$/, "");
}

export async function proxyJsonRequest(context, path, init = {}) {
  const origin = requireBackendOrigin(context.env);
  const url = `${origin}${path}`;
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), DEFAULT_BACKEND_TIMEOUT_MS);

  try {
    const response = await fetch(url, {
      ...init,
      signal: controller.signal,
    });

    return new Response(response.body, {
      status: response.status,
      headers: response.headers,
    });
  } finally {
    clearTimeout(timeout);
  }
}
