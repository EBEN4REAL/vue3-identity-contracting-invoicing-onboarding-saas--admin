Feature: Service Provider - Settings

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/settings"
    Then the Element with Cypress ID "color-picker-title" should NOT exist
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/settings"
    Then the Element with Cypress ID "color-picker-title" should NOT exist
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Success with SP Admin from direct URL
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Service Provider "000"
    When the User navigates to "/sp/settings"
    Then the Element with Cypress ID "color-picker-title" should be visible

  Scenario: Success with SP Editor from direct URL
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "000"
    When the User navigates to "/sp/settings"
    Then the Element with Cypress ID "color-picker-title" should be visible

  Scenario: Success with SP Viewer from direct URL
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "000"
    When the User navigates to "/sp/settings"
    Then the Element with Cypress ID "color-picker-title" should be visible

  Scenario: Color picker default color and in View Mode
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Service Provider "000"
    When the User navigates to "/sp/settings"
    And the User should be redirected to "/sp/settings"
    And the Element with selector ".mm-app-layout" should be visible
    Then the Element with Cypress ID "button-edit" should be visible
    And the Element with Cypress ID "color-picker-title" should be visible
    And the Element with Cypress ID "color-picker-text" should have the value as "#072e51"
    And the Element with Cypress ID "button-edit" should be visible

  Scenario: Success changing button color to light/dark background
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Service Provider "000"
    And the User navigates to "/sp/settings"
    When the User clicks on the Element with Cypress ID "button-edit"
    And the User clicks on the Element with Cypress ID "color-picker-button"
    Then the Element with selector "#color-picker-selector" sets the color to "711EAA"
    And the Element with Cypress ID "color-picker-button" should have the color "rgb(113, 30, 170)"
    And the Element with Cypress ID "color-picker-button" should have the text color "rgba(0, 0, 0, 0.87)"
    And the Element with selector "#color-picker-selector" sets the color to "BEBEA1"
    And the Element with Cypress ID "color-picker-button" should have the color "rgb(190, 190, 161)"
    And the Element with Cypress ID "color-picker-button" should have the text color "rgba(0, 0, 0, 0.87)"

  Scenario: Valid image file
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Service Provider "000"
    And the User navigates to "/sp/settings"
    And the Element with Cypress ID "logo-uploader" should exist
    And the user uploads a file with path "cypress/cucumber/fixtures/logo-upload-success.jpg" to input with Cypress ID "logo-uploader"
    When the User clicks on the Element with Cypress ID "button-edit"
    And the Element with Cypress ID "button-save-settings" should be NOT disabled
    And the Element with Cypress ID "replace-logo" should be visible
    And the User clicks on the Element with Cypress ID "button-cancel-settings"
    And the Element with Cypress ID "dialog-discard-changes" should be visible
    And the User clicks on the Element with Cypress ID "button-cancel"
    And the Element with Cypress ID "dialog-discard-changes" should NOT exist
    And the User clicks on the Element with Cypress ID "button-cancel-settings"
    And the User clicks on the Element with Cypress ID "button-submit"
    Then the Element with Cypress ID "button-cancel-settings" should NOT exist

  Scenario: Success Upload brand logo and icon and edit
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Service Provider "000"
    And the User navigates to "/sp/settings"
    And the Element with Cypress ID "logo-uploader" should exist
    When the user uploads a file with path "cypress/cucumber/fixtures/logo-upload-success.jpg" to input with Cypress ID "logo-uploader"
    And the IAM Service Providers has been intercepted to upload a logo for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers has been intercepted to update button colors for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "button-edit"
    And the User clicks on the Element with Cypress ID "button-save-settings"
    And the Element with Cypress ID "button-edit" should be visible
    And the Element with Cypress ID "replace-logo" should NOT exist
    And the User clicks on the Element with Cypress ID "button-edit"
    Then the Element with Cypress ID "button-save-settings" should be visible

  Scenario: Invalid image file
    Given the User "007" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the User navigates to "/sp/settings"
    And the Element with Cypress ID "logo-uploader" should exist
    When the user uploads a file with path "cypress/cucumber/fixtures/logo-upload-small.svg" to input with Cypress ID "logo-uploader"
    Then the Element with Cypress ID "error-message" should exist
