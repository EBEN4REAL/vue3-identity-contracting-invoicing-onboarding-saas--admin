<script setup lang="ts">
import { configurationService } from "~/configuration/configuration.service";
import { onMounted, ref, Ref } from "vue";
import { authService } from "~/auth/auth.service";
import {
  SectionReadWithData,
  WizardCreate,
  WizardReadWithSections,
} from "~/configuration/configuration.types";
import { eventBus } from "~/mm_ui_kit/src/helpers/EventBus";
import { useRoute, useRouter } from "vue-router";

const WIZARD_TYPE_ID: string = "8951ad19-c8ba-4726-b850-d0fd58d04506";

const route = useRoute();
const router = useRouter();
const serviceProviderId: Ref<string | null> = ref(null);
const wizard: Ref<WizardReadWithSections | null> = ref(null);
const sections: Ref<SectionReadWithData[] | null> = ref(null);
const name: Ref<string | null> = ref(null);

const createWizard = async () => {
  const payload: WizardCreate = {
    wizard_type_id: WIZARD_TYPE_ID,
    name: name.value as string,
  };
  try {
    wizard.value = await configurationService.createWizard(
      serviceProviderId.value as string,
      payload,
    );
    await router.push(
      `/sp/wizards/basic-application/${wizard.value.id as string}`,
    );
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  }
};

const readSections = async () => {
  if (!wizard.value) {
    return;
  }
  sections.value = await Promise.all(
    wizard.value?.sections.map((section) =>
      configurationService.getSection(
        serviceProviderId.value as string,
        section.id,
      ),
    ),
  );
};

const readWizard = async () => {
  wizard.value = await configurationService.getWizard(
    serviceProviderId.value as string,
    route.params.wizard_id as string,
  );
  name.value = wizard.value?.name;
  await readSections();
};

const updateSection = async (sectionId: string) => {
  try {
    await configurationService.updateSection(
      serviceProviderId.value as string,
      sectionId,
      {
        data: {
          roles: [
            {
              name: `${name.value} role ${Math.random().toString(36).substring(7)}`,
              description: "new role",
            },
          ],
        },
      },
    );
    await readWizard();
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  }
};

const publishWizard = async () => {
  try {
    await configurationService.publishWizard(
      serviceProviderId.value as string,
      wizard.value?.id as string,
    );
    await readWizard();
  } catch (error) {
    eventBus.$emit("onShowToast", {
      text: error,
      status: "error",
    });
  }
};

onMounted(async () => {
  const userProfile = await authService.getProfile();
  if (userProfile?.sp_org) {
    serviceProviderId.value = userProfile.sp_org;
  }
  if (route.params.wizard_id) {
    await readWizard();
  }
});
</script>

<template>
  <m-m-input v-model="name" label="Name" :is-disabled="wizard" />
  <template v-if="sections">
    <div v-for="section in sections" :key="section.id">
      <div>{{ section.type.name }}</div>
      <div>
        STATUS: {{ section.status }}, SYNC STATUS: {{ section.sync_status }}
        <m-m-button @click="updateSection(section.id)">Update</m-m-button>
      </div>
    </div>
  </template>
  <m-m-button
    v-if="!wizard"
    :is-disabled="!serviceProviderId || !name"
    @click="createWizard"
  >
    Create
  </m-m-button>
  <m-m-button v-if="wizard?.config" @click="publishWizard">Publish</m-m-button>
</template>
