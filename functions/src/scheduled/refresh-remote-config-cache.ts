import { onSchedule } from "firebase-functions/v2/scheduler";

import { refreshRemoteConfigCache as refreshCache } from "../shared/remote-config-cache";
import { withFailureAlerting } from "../shared/function-health";

/**
 * Her 2 saatte bir Remote Config şablonunu tek seferlik çekip
 * `internal/remoteConfigCache`'e yazar — diğer tüm fonksiyonlar bunun
 * yerine bu cache'i okur (bkz. `shared/remote-config-cache.ts`).
 */
export const refreshRemoteConfigCache = onSchedule(
  "every 2 hours",
  withFailureAlerting("refreshRemoteConfigCache", refreshCache),
);
