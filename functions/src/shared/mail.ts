import { getFirestore } from "firebase-admin/firestore";

/**
 * F5-2 — Firebase "Trigger Email" extension'ının izlediği `mail`
 * koleksiyonuna yazar; extension bu dokümanı görünce e-postayı gerçekten
 * gönderir (Brevo SMTP üzerinden — bkz. `extensions/firestore-send-email.env`).
 */
export async function queueEmail(params: { to: string; subject: string; html: string }): Promise<void> {
  await getFirestore().collection("mail").add({
    to: [params.to],
    message: { subject: params.subject, html: params.html },
  });
}
