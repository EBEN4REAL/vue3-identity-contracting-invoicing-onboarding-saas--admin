import { defineStore } from "pinia";
import { RouteRecordNameGeneric } from "vue-router";

type TypeUseRouteStoreState = {
  previousRouteName: RouteRecordNameGeneric | null;
  previousRoutePath: string | null;
};

export const useRouteStore = defineStore("useRouteStore", {
  state: (): TypeUseRouteStoreState => ({
    previousRouteName: null,
    previousRoutePath: null,
  }),
  persist: true,
});
