import { getFirestore } from "firebase-admin/firestore";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";

const DEFAULT_DELAY_MINUTES = 30;

function readDefaultDelayMinutes(template: RemoteConfigTemplate): number {
  const param = template.parameters["cfg_default_trainer_reminder_delay_minutes"];
  const raw = param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
  const parsed = Number.parseInt(raw ?? "", 10);
  return Number.isFinite(parsed) ? parsed : DEFAULT_DELAY_MINUTES;
}

/**
 * Admin, Yetki Ayarları'ndan her antrenöre farklı bir "seans bitince kaç
 * dakika sonra tamamlama sorusu gitsin" süresi setleyebiliyor
 * (`gyms/{gymId}.trainerPermissions.{trainerId}.trainerReminderDelayMinutes`,
 * bkz. `trainer_permissions_controller.dart` — UI zaten vardı, sadece
 * server tarafı hiç okumuyordu). Override yoksa RC'deki
 * `cfg_default_trainer_reminder_delay_minutes`e (zaten cache'ten okunan
 * template üzerinden, ekstra fetch maliyeti yok) düşülür.
 */
export async function resolveTrainerCompletionDelayMinutes(
  gymId: string | undefined,
  trainerId: string | undefined,
  template: RemoteConfigTemplate,
): Promise<number> {
  const fallback = readDefaultDelayMinutes(template);
  if (!gymId || !trainerId) return fallback;

  const gymDoc = await getFirestore().collection("gyms").doc(gymId).get();
  const override = gymDoc.data()?.trainerPermissions?.[trainerId]?.trainerReminderDelayMinutes as
    | number
    | undefined;
  return typeof override === "number" && Number.isFinite(override) ? override : fallback;
}
