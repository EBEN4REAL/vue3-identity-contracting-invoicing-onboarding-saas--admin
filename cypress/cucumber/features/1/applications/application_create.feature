Feature: Applications - Create

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/edf44f93-2b8f-4255-b7ed-23558fc46be2/applications/new"
    Then the Element with Cypress ID "application-details-read" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  # TODO: We need to change the Configuration OAuth Client endpoint to include the Attribute Set data
  Scenario: Should create new Application
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/new"
    And the intercepted requests have resolved
    And the Element with Cypress ID "button-assign-organization-attribute-set" should NOT exist
    And the Element with Cypress ID "button-assign-user-attribute-set" should NOT exist
    And the User types "Auth Client 001" in Input inside Element with Cypress ID "input-application-name"
    And the User types "www.test.com" in Input inside Element with Cypress ID "input-application-url"
    And the Input inside Element with Cypress ID "input-application-url" should have the value as "https://www.test.com"
    And the User clicks on the Element with Cypress ID "website-radio-button-label"
    And the User types "Client 001" in Textarea inside Element with Cypress ID "input-application-description"
    And the User clicks on the Element with Cypress ID "tab-item-connection-configuration"
    And the User types "www.test.com" in Input inside Element with Cypress ID "input-application-redirect-url-0"
    And the Configuration POST OAuth Clients request has been intercepted to create and return the OAuth Client "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "copy-secret-key"
    Then the Element with Cypress ID "success-copy-alert" should exist
    And the Element with Cypress ID "dialog-secret-successfully-created dialog-title" contains the text as "Your application is successfully created"
    And the Input inside Element with Cypress ID "dialog-secret-successfully-created input-application-client-secret-key" should have the value as "eXXKP&TP<<rUwR[x9|8s"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Policies for OAuth Client request has been intercepted to return policies "001" for OAuth Client "001" for Service Provider "001"
#    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "dialog-secret-successfully-created dialog-close-button"
    And the intercepted requests have resolved
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"

  Scenario: Should discard creating new Application
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/new"
    And the intercepted requests have resolved
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-discard"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/configuration#Applications"

  Scenario: Should show dialog Unsaved changes when user leaves page
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/new"
    And the intercepted requests have resolved
    And the User types "Auth Client 001" in Input inside Element with Cypress ID "input-application-name"
    And the User clicks on the Element with selector "#app-navigation-configuration"
    And the Element with Cypress ID "dialog-unsaved-changes" should exist
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "dialog-unsaved-changes button-switch-anyway"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/configuration"
