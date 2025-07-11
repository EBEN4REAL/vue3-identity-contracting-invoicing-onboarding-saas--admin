<script lang="ts" setup>
import {
  ref,
  Ref,
  watch,
  computed,
  onMounted,
  ComputedRef,
  reactive,
} from "vue";
import { helpers, required } from "@vuelidate/validators";
import {
  AddUserToOrganizationFormRules,
  TypeAddUserToOrganizationForm,
} from "~/service-providers/AccessControl/Organizations/Organizations.types";
import useVuelidate from "@vuelidate/core";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { emailValidator } from "~/mm_ui_kit/src/helpers/emailValidator";
import {
  OrganizationUsersCreate,
  PaginationSchema_OrganizationRead_,
} from "~/iam/iam.types";
import { TableRequestParams } from "~/mm_ui_kit/src/types/table.types";
import { authService } from "~/auth/auth.service";
import { ITEMS_PER_PAGE } from "~/common/constants";
import OrganizationCreateModal from "./OrganizationCreateModal.vue";
import { showToast } from "~/mm_ui_kit/src/composables/useToast";

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false,
  },
  context: { type: String, default: "account" },
});

const intialQueryParams: TableRequestParams = {
  limit: ITEMS_PER_PAGE[0],
  offset: "0",
};

const isDialogCreateCustomerOpen: Ref<boolean> = ref(false);
const isAlertVisible: Ref<boolean> = ref(false);
const alertText: Ref<string> = ref("");
const isButtonSubmitLoading: Ref<boolean> = ref(false);
const isGetOrganizationsLoading: Ref<boolean> = ref(false);
const selectedOrganization: Ref<{ name: string; id: string } | null> =
  ref(null);
const organizationSearch: Ref<string> = ref("");
const accountToAdd: Ref<string> = ref("");
const serviceProviderId: Ref<string> = ref("");
const isnewUserForm: Ref<boolean> = ref(false);
const organizations: Ref<PaginationSchema_OrganizationRead_ | null> = ref(null);

const newUserForm = reactive<TypeAddUserToOrganizationForm>({
  emails: [],
});

const formRules: AddUserToOrganizationFormRules = {
  emails: {
    required: helpers.withMessage("Emails are required", required),
    emails: helpers.withMessage(
      "Check the format of email address",
      emailValidator,
    ),
  },
};

const v$ = useVuelidate(formRules, newUserForm, { $scope: "inviteUsers" });

const emit = defineEmits(["close", "submit"]);

const isButtonSubmitDisabled: ComputedRef<boolean> = computed(
  () =>
    isButtonSubmitLoading.value ||
    v$.value.emails.$invalid ||
    newUserForm.emails.length === 0 ||
    !selectedOrganization.value,
);

const getOrganizations = async (params: TableRequestParams) => {
  if (!serviceProviderId.value) return;
  try {
    isGetOrganizationsLoading.value = true;
    organizations.value =
      await serviceProvidersService.getServiceProviderOrganizations(
        serviceProviderId.value,
        params,
      );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching organizations",
      status: "error",
    });
  } finally {
    isGetOrganizationsLoading.value = false;
  }
};

const submit = async () => {
  const inviteUsersRequest: OrganizationUsersCreate = {
    users: newUserForm.emails.map((email: string) => ({
      email,
    })),
  };

  try {
    isButtonSubmitLoading.value = true;
    await serviceProvidersService.createSPOrganizationUsers(
      serviceProviderId.value,
      selectedOrganization.value?.id || "",
      inviteUsersRequest,
    );
    emit("submit");
    emit("close");
    showToast({
      text: "Users added successfully",
      status: "success",
    });
  } catch (error) {
    isAlertVisible.value = true;
    alertText.value = "Failed to create organization users";
  } finally {
    isButtonSubmitLoading.value = false;
  }
};

const organizationsForMultiselect: ComputedRef<
  { id: string; name: string }[] | undefined
> = computed(() =>
  organizations.value?.results.map(({ organization }) => ({
    id: organization.id,
    name: organization.name,
  })),
);

const onCreateCustomerDialogOpen = () => {
  isDialogCreateCustomerOpen.value = true;
  accountToAdd.value = organizationSearch.value;
};

const onCreateCustomerDialogClose = () => {
  isDialogCreateCustomerOpen.value = false;
};

const totalOrganizations: ComputedRef<number> = computed(
  () => organizations.value?.total || 0,
);

const isAfterListContentVisible: ComputedRef<boolean> = computed(
  () =>
    Boolean(organizationSearch.value) &&
    !isGetOrganizationsLoading.value &&
    !organizations.value?.results.find(
      (organization) =>
        organization.organization.name === organizationSearch.value,
    ),
);

const createCustomerText: ComputedRef<string> = computed(
  () => `Add ${organizationSearch.value} account`,
);

const onSearchChange = (value: string) => {
  organizationSearch.value = value;
};

watch(
  () => props.isOpen,
  () => {
    newUserForm.emails = [];
    selectedOrganization.value = null;
    v$.value.$reset();
  },
);

const handleCreateCustomer = (organization: { name: string; id: string }) => {
  selectedOrganization.value = organization;
  isnewUserForm.value = true;
};

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
  await getOrganizations(intialQueryParams);
});
</script>

<template>
  <m-m-dialog
    :is-open="isOpen"
    size="medium"
    title="Add user to account"
    subtitle="Add users to an existing or new account"
    icon="user-plus"
    @close="emit('close')"
  >
    <template #default>
      <form v-mm-focus-first class="mm-page-dialog-form">
        <m-m-multiselect
          ref="multiselectRef"
          v-model="selectedOrganization"
          :options="organizationsForMultiselect"
          :total="totalOrganizations"
          label="Search & add account"
          item-value="id"
          item-title="name"
          required
          :loading="isGetOrganizationsLoading"
          searchable
          @search-change="onSearchChange"
          @update-params="getOrganizations"
        >
          <template v-if="isAfterListContentVisible" #afterListContent>
            <m-m-button @click="onCreateCustomerDialogOpen">
              {{ createCustomerText }}
            </m-m-button>
          </template>
        </m-m-multiselect>
        <m-m-tags-input
          v-model="newUserForm.emails"
          label="Email address"
          placeholder="Add one or more email addresses"
          type="email"
          required
          :errors="v$.emails.$errors"
          @blur="v$.emails.$touch"
        />
      </form>
    </template>
    <template #footer>
      <m-m-button variant="outlined" cy="button-cancel" @click="emit('close')">
        Cancel
      </m-m-button>
      <m-m-button
        variant="elevated"
        :disabled="isButtonSubmitDisabled"
        :loading="isButtonSubmitLoading"
        cy="button-submit"
        prepend-icon="plus-white"
        @click="submit"
      >
        Create
      </m-m-button>

      <organization-create-modal
        :selected-organization="accountToAdd"
        :is-open="isDialogCreateCustomerOpen"
        :service-provider-id="serviceProviderId"
        @close="onCreateCustomerDialogClose"
        @submit="emit('close')"
        @on:create-customer="handleCreateCustomer"
      />
    </template>
  </m-m-dialog>
</template>

<style scoped lang="scss">
.icon-background {
  background-color: #f4f5f7;
  padding: 8px;
  border-radius: 8px;
}
</style>
