import { HttpsError, onCall } from "firebase-functions/v2/https";

import { mintLoginToken } from "../shared/login-token";
import { verifyOtp } from "../shared/otp";

function reasonToCode(reason: "expired" | "locked" | "invalid"): "deadline-exceeded" | "resource-exhausted" | "invalid-argument" {
  switch (reason) {
    case "expired":
      return "deadline-exceeded";
    case "locked":
      return "resource-exhausted";
    case "invalid":
      return "invalid-argument";
  }
}

/** `startLogin`'in ikinci adımı — OTP doğrulanınca custom token üretir (F1-10). */
export const verifyLoginOtp = onCall(async (request) => {
  const uid = typeof request.data?.uid === "string" ? request.data.uid : "";
  const code = typeof request.data?.code === "string" ? request.data.code : "";
  if (!uid || !code) {
    throw new HttpsError("invalid-argument", "uid ve kod gerekli.");
  }

  const result = await verifyOtp({ purpose: "login", uid, code });
  if (!result.ok) {
    throw new HttpsError(reasonToCode(result.reason), "Kod doğrulanamadı.");
  }

  const token = await mintLoginToken(uid);
  return { token };
});
