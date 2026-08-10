import { initializeApp } from "firebase-admin/app";

initializeApp();

export { helloWorld } from "./callable/hello-world";
export { requestCustomToken } from "./callable/request-custom-token";
export { deleteAccount } from "./callable/delete-account";
export { onUserRoleAssigned } from "./triggers/on-user-role-assigned";
export { sessionReminderCheck } from "./scheduled/session-reminder-check";
export { sessionCompletionCheck } from "./scheduled/session-completion-check";
export { badgeCheck } from "./scheduled/badge-check";
export { weeklyGymReport } from "./scheduled/weekly-gym-report";
export { weeklyAccountingReport } from "./scheduled/weekly-accounting-report";
export { weeklyTrainerReport } from "./scheduled/weekly-trainer-report";
