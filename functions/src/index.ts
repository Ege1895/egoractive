import { initializeApp } from "firebase-admin/app";

initializeApp();

export { helloWorld } from "./callable/hello-world";
export { requestCustomToken } from "./callable/request-custom-token";
export { deleteAccount } from "./callable/delete-account";
export { verifySubscriptionPurchase } from "./callable/verify-subscription-purchase";
export { onUserRoleAssigned } from "./triggers/on-user-role-assigned";
export { sessionReminderCheck } from "./scheduled/session-reminder-check";
export { sessionCompletionCheck } from "./scheduled/session-completion-check";
export { badgeCheck } from "./scheduled/badge-check";
export { weeklyGymReport } from "./scheduled/weekly-gym-report";
export { weeklyAccountingReport } from "./scheduled/weekly-accounting-report";
export { weeklyTrainerReport } from "./scheduled/weekly-trainer-report";
export { feedbackReminderCheck } from "./scheduled/feedback-reminder-check";
export { monthlyFeedbackSummary } from "./scheduled/monthly-feedback-summary";
export { weeklySubscriberSummary } from "./scheduled/weekly-subscriber-summary";
