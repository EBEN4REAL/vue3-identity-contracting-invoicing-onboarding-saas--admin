import { defineStore } from "pinia";
import { policiesService } from "~/service-providers/policies.service";
import { PolicyCategoryReadLimited } from "~/service-providers/ConfigurationTabs/Policies/policies.types";

interface PolicyUxCategoriesState {
  policyUxCategories: PolicyCategoryReadLimited;
  activeCategory: string;
}

export const usePolicyUxCategoriesStore = defineStore("policyUxCategories", {
  state: (): PolicyUxCategoriesState => ({
    policyUxCategories: [],
    activeCategory: "",
  }),
  getters: {
    activeCategoryName(): string | undefined {
      const activeCategoryObj = this.policyUxCategories.find(
        (policy) => policy.id === this.activeCategory,
      );
      return activeCategoryObj?.name;
    },
  },
  actions: {
    async fetchPolicyUxCategories() {
      this.policyUxCategories = await policiesService.getPolicyTypeCategories();
    },
    setActiveCategory(categoryId: string) {
      this.activeCategory = categoryId;
    },
  },
  persist: true,
});
