import assert from "node:assert/strict";
import test from "node:test";

import type { BatchResponse } from "firebase-admin/messaging";

import { collectDeadTokens } from "./dead-token-cleanup";

/** `sendEachForMulticast` yanıtının test için gereken en küçük hâli. */
function batchResponse(codes: (string | null)[]): BatchResponse {
  const responses = codes.map((code) =>
    code === null
      ? { success: true, messageId: "ok" }
      : { success: false, error: { code, message: code } },
  );
  return {
    responses,
    successCount: codes.filter((c) => c === null).length,
    failureCount: codes.filter((c) => c !== null).length,
  } as unknown as BatchResponse;
}

test("collectDeadTokens kayıtsız token'ı ayıklar", () => {
  const tokens = ["canlı", "ölü", "canlı2"];
  const response = batchResponse([null, "messaging/registration-token-not-registered", null]);
  assert.deepEqual(collectDeadTokens(tokens, response), ["ölü"]);
});

test("collectDeadTokens geçersiz kayıt token'ını da ayıklar", () => {
  const response = batchResponse(["messaging/invalid-registration-token"]);
  assert.deepEqual(collectDeadTokens(["bozuk"], response), ["bozuk"]);
});

// EN KRİTİK TEST: bozuk bir bildirim METNİ tüm token'lar için
// `invalid-argument` döndürür. Bu kod ölü sayılsaydı tek bir hatalı
// gönderim salonun BÜTÜN token'larını silerdi.
test("collectDeadTokens invalid-argument'ı ölü SAYMAZ", () => {
  const tokens = ["a", "b", "c"];
  const response = batchResponse([
    "messaging/invalid-argument",
    "messaging/invalid-argument",
    "messaging/invalid-argument",
  ]);
  assert.deepEqual(collectDeadTokens(tokens, response), []);
});

test("collectDeadTokens geçici hataları ölü saymaz", () => {
  const response = batchResponse(["messaging/server-unavailable", "messaging/internal-error", "messaging/quota-exceeded"]);
  assert.deepEqual(collectDeadTokens(["a", "b", "c"], response), []);
});

test("collectDeadTokens hepsi başarılıyken boş liste döner", () => {
  assert.deepEqual(collectDeadTokens(["a", "b"], batchResponse([null, null])), []);
});

// Eşleme sıraya dayanıyor (FCM sözleşmesi: responses[i] <-> tokens[i]);
// yanlış token'ı silmemek için doğru indeksin seçildiği doğrulanıyor.
test("collectDeadTokens doğru indeksteki token'ı seçer", () => {
  const tokens = ["t0", "t1", "t2", "t3"];
  const response = batchResponse([null, "messaging/registration-token-not-registered", null, "messaging/registration-token-not-registered"]);
  assert.deepEqual(collectDeadTokens(tokens, response), ["t1", "t3"]);
});

test("collectDeadTokens yanıt token sayısından uzunsa taşmaz", () => {
  const response = batchResponse(["messaging/registration-token-not-registered", "messaging/registration-token-not-registered"]);
  assert.deepEqual(collectDeadTokens(["tek"], response), ["tek"]);
});
