<script setup lang="ts">
import { MetricsChart, ServiceProviderMetrics } from "~/iam/iam.types";
import { onMounted, ref, Ref, watch } from "vue";
import { authService } from "~/auth/auth.service";
import { serviceProvidersService } from "~/service-providers/service-providers.service";
import {
  activeUsers,
  activeUsersDateRange,
  chartOptions,
  dateRanges,
  failedLoginDateRange,
  failedLogins,
  getFromDate,
  getUntilDate,
  metricsChartToChartData,
  signups,
  signupsDateRange,
} from "~/mm_ui_kit/src/helpers/metrics";
import { Line } from "vue-chartjs";
import {
  CategoryScale,
  Chart as ChartJS,
  Legend,
  LinearScale,
  LineElement,
  PointElement,
  Title,
  Tooltip,
} from "chart.js";

const serviceProviderId: Ref<string | null> = ref(null);
const serviceProviderMetrics: Ref<ServiceProviderMetrics | null> = ref(null);

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
);

const fetchActiveUsers = async () => {
  if (!serviceProviderId.value) {
    return;
  }
  const activeUsersMetrics: MetricsChart =
    await serviceProvidersService.getServiceProviderMetricsActiveUsers(
      serviceProviderId.value,
      getFromDate(activeUsersDateRange.value),
      getUntilDate(activeUsersDateRange.value),
    );
  activeUsers.value = metricsChartToChartData(activeUsersMetrics);
};

const fetchSignups = async () => {
  if (!serviceProviderId.value) {
    return;
  }
  const signupsMetrics: MetricsChart =
    await serviceProvidersService.getServiceProviderMetricsSignups(
      serviceProviderId.value,
      getFromDate(signupsDateRange.value),
      getUntilDate(signupsDateRange.value),
    );
  signups.value = metricsChartToChartData(signupsMetrics);
};

const fetchFailedLogins = async () => {
  if (!serviceProviderId.value) {
    return;
  }
  const failedLoginsMetrics: MetricsChart =
    await serviceProvidersService.getServiceProviderMetricsFailedLogins(
      serviceProviderId.value,
      getFromDate(failedLoginDateRange.value),
      getUntilDate(failedLoginDateRange.value),
    );
  failedLogins.value = metricsChartToChartData(failedLoginsMetrics);
};

onMounted(async () => {
  const profile = await authService.getProfile();
  if (profile?.sp_org) {
    serviceProviderId.value = profile.sp_org;
    serviceProviderMetrics.value =
      await serviceProvidersService.getServiceProviderMetrics(profile.sp_org);
  }
});

watch(serviceProviderId, async () => {
  await fetchActiveUsers();
  await fetchSignups();
  await fetchFailedLogins();
});

watch(activeUsersDateRange, async () => {
  await fetchActiveUsers();
});

watch(signupsDateRange, async () => {
  await fetchSignups();
});

watch(failedLoginDateRange, async () => {
  await fetchFailedLogins();
});
</script>

<template>
  <v-container>
    <v-responsive class="align-center text-center fill-height">
      <h2>Service provider dashboard</h2>
      <v-row id="sp-metrics" align="center" justify="center" class="mt-4">
        <v-col cols="auto">
          <v-card max-width="260" variant="outlined">
            <v-card-item>
              <v-card-title>Total Organizations</v-card-title>
              <v-card-subtitle
                v-if="serviceProviderMetrics"
                id="sp-total-organizations"
                class="text-red"
              >
                {{ serviceProviderMetrics.organizations.total }}
              </v-card-subtitle>
              <v-card-text v-if="!serviceProviderMetrics" class="mt-3">
                <m-m-progress-circular indeterminate />
              </v-card-text>
            </v-card-item>
          </v-card>
        </v-col>
        <v-col cols="auto">
          <v-card max-width="260" variant="outlined">
            <v-card-item>
              <v-card-title>Total users</v-card-title>
              <v-card-subtitle
                v-if="serviceProviderMetrics"
                id="sp-total-users"
                class="text-red"
              >
                {{ serviceProviderMetrics.users.total }}
              </v-card-subtitle>
              <v-card-text v-if="!serviceProviderMetrics" class="mt-3">
                <m-m-progress-circular indeterminate />
              </v-card-text>
            </v-card-item>
          </v-card>
        </v-col>
        <v-col cols="auto">
          <v-card max-width="260" variant="outlined">
            <v-card-item>
              <v-card-title>Average users per org</v-card-title>
              <v-card-subtitle
                v-if="serviceProviderMetrics"
                id="sp-average-users-per-org"
                class="text-red"
              >
                {{ serviceProviderMetrics.average_org_users.total }}
              </v-card-subtitle>
              <v-card-text v-if="!serviceProviderMetrics" class="mt-3">
                <m-m-progress-circular indeterminate />
              </v-card-text>
            </v-card-item>
          </v-card>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="12" md="6">
          <v-card>
            <v-card-title>Active users</v-card-title>
            <v-card-subtitle>
              <v-select
                v-model="activeUsersDateRange"
                label="Date Range"
                :items="dateRanges"
              />
            </v-card-subtitle>
            <v-card-text v-if="!activeUsers">
              <m-m-progress-circular indeterminate :size="64" :width="6" />
            </v-card-text>
            <v-card-text v-if="activeUsers">
              <Line
                id="active-users-chart"
                :options="chartOptions"
                :data="activeUsers"
              />
            </v-card-text>
          </v-card>
        </v-col>
        <v-col cols="12" md="6">
          <v-card>
            <v-card-title>Signups</v-card-title>
            <v-card-subtitle>
              <v-select
                v-model="signupsDateRange"
                label="Date Range"
                :items="dateRanges"
              />
            </v-card-subtitle>
            <v-card-text v-if="!signups">
              <m-m-progress-circular indeterminate :size="64" :width="6" />
            </v-card-text>
            <v-card-text v-if="signups">
              <Line
                id="signups-chart"
                :options="chartOptions"
                :data="signups"
              />
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="12" md="6">
          <v-card>
            <v-card-title>Failed logins</v-card-title>
            <v-card-subtitle>
              <v-select
                v-model="failedLoginDateRange"
                label="Date Range"
                :items="dateRanges"
              />
            </v-card-subtitle>
            <v-card-text v-if="!failedLogins">
              <m-m-progress-circular indeterminate :size="64" :width="6" />
            </v-card-text>
            <v-card-text v-if="failedLogins">
              <Line
                id="failed-logins-chart"
                :options="chartOptions"
                :data="failedLogins"
              />
            </v-card-text>
          </v-card>
        </v-col>
      </v-row>
    </v-responsive>
  </v-container>
</template>

<style scoped></style>
