import { TypeErrorResponse } from "~/mm_ui_kit/src/types/types";

export const getErrorMessage = (
  err: TypeErrorResponse,
  hasExternalName: boolean = false,
): string => {
  console.error(err);

  if (err?.response?.status === 409 || err?.response?.status === 400) {
    return hasExternalName
      ? "Please enter a unique internal name"
      : "Please enter a unique name";
  }

  return "Something went wrong";
};
