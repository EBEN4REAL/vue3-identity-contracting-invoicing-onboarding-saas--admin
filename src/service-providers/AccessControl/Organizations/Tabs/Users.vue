<script setup lang="ts">
import { computed, ComputedRef, onMounted, PropType, ref, Ref } from "vue";
import {
  OrganizationUserRead,
  PaginationSchema_ServiceProviderOrganizationUserRead_,
  ServiceProviderOrganizationUserRead,
} from "~/iam/iam.types";
import { BadgeTypes } from "~/mm_ui_kit/src/types/badge.types";
import { LAST_LOGIN_ACCESS_MAP } from "~/common/constants";
import { useRouter } from "vue-router";
import DialogInviteUsersToOrganization from "../Dialogs/DialogInviteUsersToOrganization.vue";
import { useFlag } from "@unleash/proxy-client-vue";

import { TypeDropdownItem } from "~/mm_ui_kit/src/types/dropdown.types";
import { OrganizationUserStatus } from "~/users/users.types";
import { showToast } from "~/mm_ui_kit/src/composables/useToast";
import { TypeToastStatuses } from "~/mm_ui_kit/src/types/toast.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { authService } from "~/auth/auth.service";
import { serviceProvidersService } from "~/service-providers/service-providers.service";

const router = useRouter();
const isSPManageInvitesEnabled = useFlag("sp_manage_invites");

const props = defineProps({
  id: {
    type: String,
    required: true,
  },
  users: {
    type: Object as PropType<PaginationSchema_ServiceProviderOrganizationUserRead_ | null>,
    required: true,
  },
  isLoading: {
    type: Boolean,
    required: true,
  },
  isSPViewerOnly: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(["updateTableParams"]);

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
    key: "last_login_date",
    label: "Last login",
  },
  {
    key: "last_login_access",
    label: "Access",
  },
  {
    key: "invite_status",
    label: "Invite status",
  },
  {
    key: "actions",
    label: "",
  },
];

const isDialogInviteUsersToOrganizationOpened: Ref<boolean> = ref(false);

const isSPEditor: Ref<boolean> = ref(false);
const serviceProviderId: Ref<string> = ref("");

const formattedUsers: ComputedRef<
  (ServiceProviderOrganizationUserRead & { fullName: string })[]
> = computed(
  () =>
    props?.users?.results?.map((user: ServiceProviderOrganizationUserRead) => {
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

const actionsInDropdown: ComputedRef<
  (user: ServiceProviderOrganizationUserRead) => TypeDropdownItem[]
> = computed(() => {
  return (row: OrganizationUserRead): TypeDropdownItem[] => {
    const actions: TypeDropdownItem[] = [
      {
        label: "View user details",
        type: "button",
        onClick: () =>
          router.push(`/sp/accounts/${props.id}/user_details/${row.id}`),
      },
    ];
    if (
      (row.organization_user.status === OrganizationUserStatus.CANCELLED ||
        row.organization_user.status === OrganizationUserStatus.PENDING) &&
      isSPManageInvitesEnabled.value
    ) {
      actions.push({
        label: "Resend invite",
        isDisabled: props.isSPViewerOnly,
        type: "button",
        onClick: () => onResendInviteToUser(row),
      });
    }
    if (
      isSPEditor.value &&
      isSPManageInvitesEnabled.value &&
      row.organization_user.status === OrganizationUserStatus.PENDING
    ) {
      actions.push({
        label: "Cancel invite",
        isDisabled: props.isSPViewerOnly,
        type: "button",
        onClick: () => onCancelInviteToUser(row),
      });
    }
    return actions;
  };
});

const onResendInviteToUser = async (row: OrganizationUserRead) => {
  try {
    await serviceProvidersService.createInvitationEmailForSPUser(
      serviceProviderId.value,
      props.id,
      row.user.id,
    );
    showToast({
      text: "Invite resent successfully",
      status: "success",
      duration: 5000,
    });
    emit("updateTableParams");
  } catch (error) {
    if (error.response?.status === 429) {
      showToast({
        text: "You can only send one invite every two minutes, please try again later",
        status: TypeToastStatuses.Warning,
        duration: 5000,
      });
      return;
    }
    showToast({
      text: "Error resending invite",
      status: TypeToastStatuses.Error,
    });
  }
};

const onCancelInviteToUser = async (row: OrganizationUserRead) => {
  try {
    await serviceProvidersService.updateSPUserStatus(
      serviceProviderId.value,
      props.id,
      row.user.id,
      { status: OrganizationUserStatus.CANCELLED },
    );
    showToast({
      text: "Invite cancelled successfully",
      status: "success",
      duration: 5000,
    });
    emit("updateTableParams");
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: "Failed to cancel user invite",
      status: "error",
    });
  }
};

const getBadgeStatus = (inviteStatus: string) => {
  switch (inviteStatus) {
    case "ACTIVE":
      return BadgeTypes.Inactive;
    case "CANCELLED":
      return BadgeTypes.Cancelled;
    case "EXPIRED":
      return BadgeTypes.Warning;
    default:
      return BadgeTypes.Active;
  }
};

const getInvitedStatus = (inviteStatus: string) => {
  switch (inviteStatus) {
    case "ACTIVE":
      return "Pending";
    case "CANCELLED":
      return "Cancelled";
    case "EXPIRED":
      return "Expired";
    default:
      return "Accepted";
  }
};

const detailedViewLink = (row: ServiceProviderOrganizationUserRead) =>
  `/sp/accounts/${props.id}/user_details/${row.id}`;

const accessMap = (access: string) => {
  return access === "ALLOW" ? BadgeTypes.Active : BadgeTypes.Warning;
};

const updateUsers = () => emit("updateTableParams");

const onOpenDialogInviteUsersToOrganization = () => {
  isDialogInviteUsersToOrganizationOpened.value = true;
};

const onCloseDialogInviteUsersToOrganization = () => {
  isDialogInviteUsersToOrganizationOpened.value = false;
};

onMounted(async () => {
  isSPEditor.value = await authService.isUserSPEditor();
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
});
</script>
<template>
  <m-m-expandable-card title="Users" cy="users-expandable">
    <m-m-table
      show-search
      empty-state="No users"
      background-color="#F2F4F7"
      :is-loading="isLoading"
      cy="users-details-table"
      :headers="headers"
      :rows="formattedUsers"
      :total-rows="users?.total"
      @update-params="emit('updateTableParams', $event)"
    >
      <template v-if="isSPManageInvitesEnabled" #action>
        <m-m-button
          color="primary"
          variant="outlined"
          size="small"
          prepend-icon="plus"
          class="mm-ml-auto mm-mb-10"
          data-cy="assign-role-button"
          :is-disabled="isSPViewerOnly"
          @click="onOpenDialogInviteUsersToOrganization"
        >
          Invite users
        </m-m-button>
      </template>
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
      <template #invite_status="{ row }">
        <m-m-badge
          :status="getBadgeStatus(row.organization_user.invite_status)"
          :text="getInvitedStatus(row.organization_user.invite_status)"
          indicator
        />
      </template>
      <template #email_address="{ row }">
        {{ row.user?.email }}
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
            :items="actionsInDropdown(row)"
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
  </m-m-expandable-card>

  <dialog-invite-users-to-organization
    :organization-id="props.id"
    :is-open="isDialogInviteUsersToOrganizationOpened"
    cy="dialog-invite-organization-users"
    @close="onCloseDialogInviteUsersToOrganization"
    @submit="updateUsers"
  />
</template>
<style scoped></style>
