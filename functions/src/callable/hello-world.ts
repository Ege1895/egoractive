import { onCall } from "firebase-functions/v2/https";

/**
 * F1-9 kabul kriteri: emulator'da çağrılabilen örnek callable function.
 */
export const helloWorld = onCall((request) => {
  const name = typeof request.data?.name === "string" ? request.data.name : "dünya";
  return { message: `Merhaba, ${name}!` };
});
