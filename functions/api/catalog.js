import { proxyJsonRequest } from "../_lib/backend.js";

export async function onRequestGet(context) {
  const headers = new Headers();

  const authorization = context.request.headers.get("Authorization");
  if (authorization) {
    headers.set("Authorization", authorization);
  }

  return proxyJsonRequest(context, "/catalog", {
    method: "GET",
    headers,
  });
}
