import { createApp } from "vue";
import App from "./App.vue";
import router from "./router/index.router";
import config from "~/mm.config.json";
import { plugin as unleashPlugin } from "@unleash/proxy-client-vue";
import { authService } from "~/auth/auth.service";
import clickOutside from "~/mm_ui_kit/src/directives/clickOutside";
import { createPinia } from "pinia";
import piniaPluginPersistedState from "pinia-plugin-persistedstate";

// Internationalization
import i18next from "i18next";
import I18NextVue from "i18next-vue";
import Backend from "i18next-http-backend";

// HTML Sanitization tool
import DOMPurify from "dompurify";

import "vuetify/styles";
import "@mdi/font/css/materialdesignicons.css";
import { createVuetify } from "vuetify";
import * as components from "vuetify/components";
import * as labsComponents from "vuetify/labs/components";
import * as directives from "vuetify/directives";
import { createGtm } from "@gtm-support/vue-gtm";
import focusFirstDirective from "./mm_ui_kit/src/directives/focusFirst";

const unleashConfig = {
  url: config.unleash.url,
  clientKey: "secret",
  refreshInterval: 15,
  appName: config.unleash.stage,
  disableMetrics: true,
};

i18next.use(Backend).init({
  lng: "en",
  interpolation: {
    escapeValue: false,
  },
  fallbackLng: false,
  backend: {
    loadPath: "/locales/{{lng}}/{{ns}}.json",
  },
});
DOMPurify.setConfig({
  ADD_ATTR: ["target"],
});

const sanitizeHtml = {
  mounted(el: HTMLElement, binding) {
    el.innerHTML = DOMPurify.sanitize(binding.value);
  },
  updated(el: HTMLElement, binding) {
    el.innerHTML = DOMPurify.sanitize(binding.value);
  },
};

const app = createApp(App);

const pinia = createPinia();

pinia.use(piniaPluginPersistedState);

app.use(router);
app.use(pinia);
app.use(
  createVuetify({
    components: {
      ...components,
      ...labsComponents,
    },
    directives,
    theme: false,
  }),
);
app.use(unleashPlugin, { config: unleashConfig });
// Force consent for Google Tag Manager by pushing default consent settings to the dataLayer
window.dataLayer = window.dataLayer || [];
window.dataLayer.push({
  consent: {
    default: {
      ad_storage: "granted",
      analytics_storage: "granted",
      functionality_storage: "granted",
      personalization_storage: "granted",
      security_storage: "granted",
    },
  },
});
app.use(
  createGtm({
    id: config.gtm.id,
    defer: false,
    compatibility: false,
    enabled: true,
    debug: true,
    loadScript: true,
    vueRouter: router,
    trackOnNextTick: false,
  }),
);

app.use(I18NextVue, { i18next });

app.directive("sanitize-html", sanitizeHtml);

app.directive("mm-click-outside", clickOutside);
app.directive("mm-focus-first", focusFirstDirective);
app.mount("#app");

app.config.globalProperties.auth = authService;
