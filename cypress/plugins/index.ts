// eslint-disable-next-line @typescript-eslint/no-var-requires
const cucumber = require("cypress-cucumber-preprocessor").default;
// eslint-disable-next-line @typescript-eslint/no-var-requires
const browserify = require("@cypress/browserify-preprocessor");

module.exports = (on: Cypress.PluginEvents) => {
  const options = {
    ...browserify.defaultOptions,
    typescript: require.resolve("typescript"),
  };

  on("file:preprocessor", cucumber(options));
};
