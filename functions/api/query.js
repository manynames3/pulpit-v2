import { proxyJsonRequest } from "../_lib/backend.js";

export async function onRequestPost(context) {
  const headers = new Headers();
  headers.set("Content-Type", "application/json");

  const authorization = context.request.headers.get("Authorization");
  if (authorization) {
    headers.set("Authorization", authorization);
  }

  return proxyJsonRequest(context, "/query", {
    method: "POST",
    headers,
    body: await context.request.text(),
  });
}

export async function onRequestOptions() {
  return new Response(null, {
    status: 204,
    headers: {
      Allow: "POST, OPTIONS",
    },
  });
}
