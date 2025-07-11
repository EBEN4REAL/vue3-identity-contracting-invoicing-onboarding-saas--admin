import { defineStore } from "pinia";

type TypeGettingStartedState = {
  isAllStepsCompleted: boolean;
};

export const useGettingStartedStore = defineStore("GettingStarted", {
  state: (): TypeGettingStartedState => ({
    isAllStepsCompleted: false,
  }),
  persist: true,
});
