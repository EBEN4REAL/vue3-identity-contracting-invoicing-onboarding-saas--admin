<script setup lang="ts">
import { useApplicationRoleBasedConfigStore } from "~/stores/useApplicationRoleBasedConfigStore";

const applicationRoleBasedConfigStore = useApplicationRoleBasedConfigStore();
</script>

<template>
  <div class="mm-mb-10 font-weight-500">Application</div>
  <div class="mm-config-applications-review">
    <m-m-input
      v-model="applicationRoleBasedConfigStore.applicationForm.name"
      label="Application name"
      class="mm-mb-10"
      disabled
      placeholder="Application name"
    />
    <div class="mm-w-10 mm-mt-10">
      <m-m-field-label label="Redirect URLs" />
      <div
        v-for="(_, index) in applicationRoleBasedConfigStore.applicationForm
          .redirectUrls"
        :key="index"
        class="mm-flex mm-mb-6 mm-flex-direction-row mm-flex-align-start mm-w-10 mm-flex-gap-6"
        tabindex="0"
      >
        <m-m-input
          v-model="
            applicationRoleBasedConfigStore.applicationForm.redirectUrls[index]
          "
          required
          class="mm-w-10"
          disabled
        />
      </div>
    </div>
  </div>
  <m-m-divider class="mm-my-12" />
  <div class="font-weight-500">Role(s) and permission(s)</div>
  <div class="mm-config-applications-roles mm-pa-10">
    <div
      v-for="role in applicationRoleBasedConfigStore.roles"
      :key="role.id"
      class="mm-mb-5"
    >
      <div class="font-weight-600">{{ role.name.name }}</div>
      <div
        v-for="permission in role.permissions"
        :key="permission.id"
        class="mm-ml-5"
      >
        <div>{{ permission.name.name }}</div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.mm-config-applications-review {
  max-width: 300px;
}
</style>
