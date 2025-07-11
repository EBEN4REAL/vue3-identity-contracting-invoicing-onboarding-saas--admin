import { defineStore } from "pinia";
import { authService } from "~/auth/auth.service";

type TypeUserRole = {
  isUserSPEditor: boolean;
  isUserSPAdmin: boolean;
  isUserSPViewer: boolean;
};

type TypeUiStore = {
  isScrimmed: boolean;
  userRole: TypeUserRole;
};

export const useUiStore = defineStore("uiStore", {
  state: (): TypeUiStore => ({
    isScrimmed: false,
    userRole: {
      isUserSPEditor: false,
      isUserSPAdmin: false,
      isUserSPViewer: false,
    },
  }),
  getters: {
    isSPViewerOnly: (state): boolean =>
      state.userRole.isUserSPViewer &&
      !state.userRole.isUserSPEditor &&
      !state.userRole.isUserSPAdmin,
  },
  actions: {
    async setUserPermissions() {
      const [isUserSPAdmin, isUserSPEditor, isUserSPViewer] = await Promise.all(
        [
          authService.isUserSPAdmin(),
          authService.isUserSPEditor(),
          authService.isUserSPViewer(),
        ],
      );
      this.userRole = {
        isUserSPAdmin,
        isUserSPEditor,
        isUserSPViewer,
      };
    },
  },
});
