<script setup lang="ts">
import { computed, ComputedRef, ref, Ref } from "vue";
import { serviceProvidersService } from "../service-providers.service";
import { ServiceProviderOrganizationUserRead } from "~/iam/iam.types";
import { authService } from "~/auth/auth.service";
import { UserProfileMM } from "~/auth/auth.types";
import {
  EmptyStateType,
  TableRequestParams,
  TableResponse,
} from "~/mm_ui_kit/src/types/table.types";
import { ITEMS_PER_PAGE } from "~/common/constants";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { LAST_LOGIN_ACCESS_MAP } from "~/common/constants";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { useRouter } from "vue-router";
import DialogAddUserToOrganization from "./Organizations/Dialogs/DialogAddUserToOrganization.vue";
import { Button } from "~/mm_ui_kit/src/types/overviewPage.types";
import { useUiStore } from "~/stores/useUiStore";

const router = useRouter();
const uiStore = useUiStore();
const userProfile: Ref<UserProfileMM | null> = ref(null);
const isLoading: Ref<boolean> = ref(false);
const serviceProviderId: Ref<string> = ref("");
const isDialogAddUsersOpened: Ref<boolean> = ref(false);
const users: Ref<TableResponse<ServiceProviderOrganizationUserRead> | null> =
  ref(null);
const forceUpdate: Ref<number> = ref(0);

const defaultPagination = { limit: ITEMS_PER_PAGE[0], offset: "0" };
const emptyState: EmptyStateType = {
  title: "No users",
  description:
    "No users from your accounts have been invited or attempted to log in to your application/s.",
  icon: "users-outline",
};
const headers = [
  {
    key: "name",
    label: "Name",
  },
  {
    key: "email_address",
    label: "Email address",
  },
  {
    key: "organization",
    label: "Account",
  },
  {
    key: "last_login_date",
    label: "Last login",
  },
  {
    key: "last_login_access",
    label: "Access",
  },
  {
    key: "actions",
    label: "",
  },
];

const handleUpdateParams = async (params: TableRequestParams) => {
  if (!userProfile.value) {
    const userProfile = await authService.getProfile();
    serviceProviderId.value = userProfile?.sp_org || "";
  }
  getUsers(params);
};

const getUsers = async (params?: TableRequestParams) => {
  isLoading.value = true;
  try {
    users.value = await serviceProvidersService.getServiceProviderUsers(
      serviceProviderId.value,
      params || defaultPagination,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Error fetching users",
      status: "error",
    });
  } finally {
    isLoading.value = false;
  }
};

const formattedUsers: ComputedRef<
  (ServiceProviderOrganizationUserRead & { fullName: string })[]
> = computed(
  () =>
    users.value?.results?.map((user: ServiceProviderOrganizationUserRead) => {
      const firstName = user.user?.first_name || "";
      const lastName = user.user?.last_name || "";
      const fullName =
        firstName || lastName ? `${firstName} ${lastName}`.trim() : "-";
      return {
        ...user,
        fullName,
      };
    }) ?? [],
);

const onOpenDialogInviteUsersToOrganization = () => {
  isDialogAddUsersOpened.value = true;
};

const onCloseDialogAddUser = () => {
  isDialogAddUsersOpened.value = false;
  const updateOrganizations = async () => {
    const userProfile = await authService.getProfile();
    if (userProfile?.sp_org) {
      serviceProviderId.value = userProfile.sp_org;
      forceUpdate.value++;
    }
  };
  updateOrganizations();
};

const onSubmit = () => handleUpdateParams(defaultPagination);

const detailedViewLink = (row: ServiceProviderOrganizationUserRead) =>
  `/sp/users/${row.organization?.id}/user_details/${row.id}`;

const accessMap = (access: string) => {
  return access === "ALLOW" ? BadgeTypes.Active : BadgeTypes.Warning;
};

const buttons: ComputedRef<Button[]> = computed(() => [
  {
    key: "add_users",
    action: onOpenDialogInviteUsersToOrganization,
    isDisabled: uiStore.isSPViewerOnly,
  },
]);
</script>

<template>
  <m-m-overview-page
    resource-id="users"
    :buttons="buttons"
    :show-config-banner="false"
  >
    <m-m-table
      :key="forceUpdate"
      show-search
      :is-loading="isLoading"
      cy="access-control-users-table"
      :headers="headers"
      :rows="formattedUsers"
      :empty-state="emptyState"
      :total-rows="users?.total"
      @update-params="handleUpdateParams"
    >
      <!--       <template #action>
        <m-m-button
          color="primary"
          variant="outlined"
          size="small"
          prepend-icon="plus"
          class="mm-ml-auto"
          data-cy="assign-role-button"
          @click="onOpenDialogInviteUsersToOrganization"
        >
          Add users
        </m-m-button>
      </template> -->
      <template #name="{ row }">
        <div class="mm-flex mm-flex-align-center">
          <m-m-link
            :to="detailedViewLink(row)"
            font-weigth="500"
            :cy="`name-${row?.id}`"
          >
            <span class="font-weight-500" :data-cy="`column-${row.id}`">
              {{ row.fullName }}
            </span>
          </m-m-link>
        </div>
      </template>
      <template #email_address="{ row }">
        {{ row.user?.email }}
      </template>
      <template #organization="{ row }">
        {{ row.organization?.name }}
      </template>
      <template #last_login_date="{ row }">
        <m-m-formatted-date :raw-date="row.last_login_date" />
      </template>
      <template #last_login_access="{ row }">
        <m-m-badge
          v-if="row.last_login_access"
          :status="accessMap(row.last_login_access as string)"
          :text="LAST_LOGIN_ACCESS_MAP[row.last_login_access]"
          :data-cy="`column-badge-${row.id}`"
        />
        <span v-else>-</span>
      </template>
      <template #actions="{ row }">
        <div class="mm-flex mm-flex-justify-end">
          <m-m-dropdown
            list-side="left"
            :items="[
              {
                label: 'View user details',
                type: 'button',
                onClick: () => router.push(detailedViewLink(row)),
              },
            ]"
            :cy="`actions-dropdown-${row.id}`"
          >
            <template #activator>
              <m-m-button
                prepend-icon="dots-vertical"
                variant="text"
                :cy="`actions-${row.id}`"
              />
            </template>
          </m-m-dropdown>
        </div>
      </template>
    </m-m-table>
  </m-m-overview-page>

  <dialog-add-user-to-organization
    :is-open="isDialogAddUsersOpened"
    @close="onCloseDialogAddUser"
    @submit="onSubmit"
  />
</template>

<style lang="scss" scoped></style>
