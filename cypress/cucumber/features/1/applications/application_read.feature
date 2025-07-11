Feature: Applications - Read

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/edf44f93-2b8f-4255-b7ed-23558fc46be2/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"
    Then the Element with selector "#title" should have the text as "404"

  # TODO: We need to change the Configuration OAuth Client endpoint to include the Attribute Set data
  Scenario: Should render details for existing Application
    Given the User "003" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Policies for OAuth Client request has been intercepted to return policies "001" for OAuth Client "001" for Service Provider "001"
    And the Onboarding GET Attribute Sets "003" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Configuration GET Attribute Set "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "004" request for Service Provider "001" has been intercepted
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "header-title" contains the text as "Auth Client 001"
    And the Element with Cypress ID "header-subtitle" contains the text as "Client 001"
    And the Element with Cypress ID "app-name" contains the text as "Auth Client 001"
    And the Element with Cypress ID "url" contains the text as "https://www.test.com"
    And the Element with Cypress ID "description" contains the text as "Client 001"
    And the Element with Cypress ID "type" contains the text as "Api"
    And the User clicks on the Element with Cypress ID "tab-item-connection-configuration"
    And the Element with Cypress ID "client-id" contains the text as "edf44f93-2b8f-4255-b7ed-23558fc46bee"
    And the Element with Cypress ID "redirect-url(s)" contains the text as "https://www.test.com"
    And the Element with Cypress ID "copy-veriam-open-id-url" contains the text as "/.well-known/openid-configuration"
    And the Element with Cypress ID "client-secret-ffd6b82d-9a04-4729-8270-89daee30b8c5" contains the text as "18 Oct 2024 10:37"
    And the User clicks on the Element with Cypress ID "tab-item-policies"
    And the Element with Cypress ID "table-policies row-0 name" contains the text as "Policy #1"
    And the Element with Cypress ID "table-policies row-0 description" contains the text as "Policy #1 Description"
    And the Element with Cypress ID "table-policies row-1 name" contains the text as "Policy #2"
    And the Element with Cypress ID "table-policies row-1 description" contains the text as "Policy #2 Description"
    And the Element with Cypress ID "table-policies row-2 name" contains the text as "Policy #3"
    And the Element with Cypress ID "table-policies row-2 description" contains the text as "Policy #3 Description"
    And the User clicks on the Element with Cypress ID "tab-item-attribute-sets"
    And the Element with Cypress ID "table-attribute-set row-0 name" contains the text as "Name #1"
    And the Element with Cypress ID "table-attribute-set row-0 description" contains the text as "Description #1"
    And the Element with Cypress ID "table-attribute-set row-0 type" contains the text as "Organization"
    And the Element with Cypress ID "table-attribute-set row-0 required_attribute_types" contains the text as "0"
    And the Element with Cypress ID "table-attribute-set row-0 optional_attribute_types" contains the text as "0"
    And the Element with Cypress ID "table-attribute-set row-1 name" contains the text as "Name #4"
    And the Element with Cypress ID "table-attribute-set row-1 description" contains the text as "Description #4"
    And the Element with Cypress ID "table-attribute-set row-1 type" contains the text as "User"
    And the Element with Cypress ID "table-attribute-set row-1 required_attribute_types" contains the text as "1"
    And the Element with Cypress ID "table-attribute-set row-1 optional_attribute_types" contains the text as "1"
    And the Element with Cypress ID "button-assign-organization-attribute-set" should exist
    And the Element with Cypress ID "button-assign-user-attribute-set" should exist

  # TODO: We need to change the Configuration OAuth Client endpoint to include the Attribute Set data
  Scenario: Should be able to assign and unassign Policies to existing Application
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Onboarding GET Attribute Sets "000" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Policies for OAuth Client request has been intercepted to return policies "000" for OAuth Client "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"
    And the intercepted requests have resolved
    And the Policies Policy Types request has been intercepted to return the Policy Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-policies"
    And the intercepted requests have resolved
    And the Policies for OAuth Client request has been intercepted to add Policies "001" for Service Provider "001" and OAuthClient "001"
    And the Policies for OAuth Client request has been intercepted to return policies "001-Updated" for OAuth Client "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-assign-policy"
    And the Element with Cypress ID "dialog-assign-policies dialog-subtitle" contains the text as "Select the policies to be assigned to Auth Client 001"
    And the User clicks on the Element with Cypress ID "select-policies autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-002"
    And the User clicks on the Element with Cypress ID "dialog-assign-policies button-submit"
    And the intercepted requests have resolved
    And the Element with Cypress ID "table-policies row-0 name" contains the text as "Policy #2"
    And the Element with Cypress ID "table-policies row-0 description" contains the text as "Policy #2 Description"
    And the Policies for OAuth Client request has been intercepted to unassign Policy "002" from OAuth Client "001" from Service Provider "001"
    And the Policies for OAuth Client request has been intercepted to return policies "000" for OAuth Client "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-92b980db-4b60-48e0-b15d-edfc96e1f3bf"
    And the User clicks on the Element with Cypress ID "actions-dropdown-92b980db-4b60-48e0-b15d-edfc96e1f3bf-item-remove-policy"
    When the User clicks on the Element with Cypress ID "dialog-unassign-policies button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-policies row-0 name" should NOT exist
