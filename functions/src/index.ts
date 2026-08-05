import { initializeApp } from "firebase-admin/app";

initializeApp();

export { helloWorld } from "./callable/hello-world";
export { requestCustomToken } from "./callable/request-custom-token";
