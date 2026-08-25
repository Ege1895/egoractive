import { initializeApp } from "firebase-admin/app";

initializeApp();

export { requestCustomToken } from "./callable/request-custom-token";
export { signupGymAdmin } from "./callable/signup-gym-admin";
export { deleteAccount } from "./callable/delete-account";
export { checkPhoneAvailable } from "./callable/check-phone-available";
export { verifySubscriptionPurchase } from "./callable/verify-subscription-purchase";
export { sendManualNotification } from "./callable/send-manual-notification";
export { onUserRoleAssigned } from "./triggers/on-user-role-assigned";
export { onSessionWriteScheduleReminder } from "./triggers/on-session-write-schedule-reminder";
export { sendSessionReminderTask } from "./tasks/send-session-reminder-task";
export { sessionCompletionCheck } from "./scheduled/session-completion-check";
export { badgeCheck } from "./scheduled/badge-check";
export { weeklyGymReport } from "./scheduled/weekly-gym-report";
export { weeklyAccountingReport } from "./scheduled/weekly-accounting-report";
export { weeklyTrainerReport } from "./scheduled/weekly-trainer-report";
export { feedbackReminderCheck } from "./scheduled/feedback-reminder-check";
export { monthlyFeedbackSummary } from "./scheduled/monthly-feedback-summary";
export { weeklySubscriberSummary } from "./scheduled/weekly-subscriber-summary";
export { trialExpiryCheck } from "./scheduled/trial-expiry-check";
