Feature: Applications - Edit

  # TODO: We need to change the Configuration OAuth Client endpoint to include the Attribute Set data
  Scenario: Should update existing Application
    Given the User "003" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Policies for OAuth Client request has been intercepted to return policies "001" for OAuth Client "001" for Service Provider "001"
    And the Onboarding GET Attribute Sets "003" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Configuration GET Attribute Set "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "004" request for Service Provider "001" has been intercepted
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit"
    And the User types "Auth Client 001 UPDATED" in Input inside Element with Cypress ID "input-application-name"
    And the User types "www.test-updated.com" in Input inside Element with Cypress ID "input-application-url"
    And the Input inside Element with Cypress ID "input-application-url" should have the value as "https://www.test-updated.com"
    And the User clicks on the Element with Cypress ID "website-radio-button-label"
    And the User types "Client 001 UPDATED" in Textarea inside Element with Cypress ID "input-application-description"
    And the User clicks on the Element with Cypress ID "tab-item-connection-configuration"
    And the User types "www.test-updated.com" in Input inside Element with Cypress ID "input-application-redirect-url-0"
    And the User clicks on the Element with Cypress ID "button-add-redirect-url"
    And the User types "www.test-2.com" in Input inside Element with Cypress ID "input-application-redirect-url-1"
    And the Configuration PATCH OAuth Client request has been intercepted to update the Oauth Client "001" for Service Provider "001" and return "001-Updated"
    When the User clicks on the Element with Cypress ID "button-save"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "header-title" contains the text as "Auth Client 001 UPDATED"
    And the Element with Cypress ID "header-subtitle" contains the text as "Client 001 UPDATED"
    And the User clicks on the Element with Cypress ID "tab-item-basic-information"
    And the Element with Cypress ID "app-name" contains the text as "Auth Client 001 UPDATED"
    And the Element with Cypress ID "url" contains the text as "https://www.test-updated.com"
    And the Element with Cypress ID "description" contains the text as "Client 001 UPDATED"
    And the Element with Cypress ID "type" contains the text as "Website"
    And the User clicks on the Element with Cypress ID "tab-item-connection-configuration"
    And the Element with Cypress ID "redirect-url(s)" contains the text as "https://www.test-updated.com"
    And the Element with Cypress ID "redirect-url(s)" contains the text as "www.test-2.com"

  # TODO: We need to change the Configuration OAuth Client endpoint to include the Attribute Set data
  Scenario: Should discard update existing Application with changes
    Given the User "003" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Policies for OAuth Client request has been intercepted to return policies "001" for OAuth Client "001" for Service Provider "001"
    And the Onboarding GET Attribute Sets "003" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Configuration GET Attribute Set "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "004" request for Service Provider "001" has been intercepted
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit"
    And the User types "Auth Client 001 UPDATED" in Input inside Element with Cypress ID "input-application-name"
    And the User types "https://www.test-updated.com" in Input inside Element with Cypress ID "input-application-url"
    And the User clicks on the Element with Cypress ID "website-radio-button-label"
    And the User types "Client 001 UPDATED" in Textarea inside Element with Cypress ID "input-application-description"
    And the User clicks on the Element with Cypress ID "tab-item-connection-configuration"
    And the User types "www.test-updated.com" in Input inside Element with Cypress ID "input-application-redirect-url-0"
    And the User clicks on the Element with Cypress ID "button-add-redirect-url"
    And the User types "www.test-2.com" in Input inside Element with Cypress ID "input-application-redirect-url-1"
    And the User clicks on the Element with Cypress ID "button-discard"
    When the User clicks on the Element with Cypress ID "dialog-unsaved-changes button-switch-anyway"
    Then the Element with Cypress ID "header-title" contains the text as "Auth Client 001"
    And the Element with Cypress ID "header-subtitle" contains the text as "Client 001"
    And the User clicks on the Element with Cypress ID "tab-item-basic-information"
    And the Element with Cypress ID "app-name" contains the text as "Auth Client 001"
    And the Element with Cypress ID "url" contains the text as "https://www.test.com"
    And the Element with Cypress ID "description" contains the text as "Client 001"
    And the Element with Cypress ID "type" contains the text as "Api"
    And the User clicks on the Element with Cypress ID "tab-item-connection-configuration"
    And the Element with Cypress ID "redirect-url(s)" contains the text as "https://www.test.com"

  # TODO: We need to change the Configuration OAuth Client endpoint to include the Attribute Set data
  Scenario: Should discard update existing Application without changes
    Given the User "003" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Policies for OAuth Client request has been intercepted to return policies "001" for OAuth Client "001" for Service Provider "001"
    And the Onboarding GET Attribute Sets "003" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Configuration GET Attribute Set "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "004" request for Service Provider "001" has been intercepted
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit"
    And the User clicks on the Element with Cypress ID "button-discard"
    When the User clicks on the Element with Cypress ID "dialog-confirm-discard button-submit"
    Then the Element with Cypress ID "header-title" contains the text as "Auth Client 001"
    And the Element with Cypress ID "header-subtitle" contains the text as "Client 001"
    And the User clicks on the Element with Cypress ID "tab-item-basic-information"
    And the Element with Cypress ID "app-name" contains the text as "Auth Client 001"
    And the Element with Cypress ID "url" contains the text as "https://www.test.com"
    And the Element with Cypress ID "description" contains the text as "Client 001"
    And the Element with Cypress ID "type" contains the text as "Api"
    And the User clicks on the Element with Cypress ID "tab-item-connection-configuration"
    And the Element with Cypress ID "redirect-url(s)" contains the text as "https://www.test.com"

  # TODO: We need to change the Configuration OAuth Client endpoint to include the Attribute Set data
  Scenario: Should assign Attribute Sets to existing Application
    Given the User "003" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Onboarding GET Attribute Sets "000" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Policies for OAuth Client request has been intercepted to return policies "001" for OAuth Client "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-attribute-sets"
    And the Configuration GET Organization Attribute Sets "001" request for Service Provider "001" has been intercepted
    And the User clicks on the Element with Cypress ID "button-assign-organization-attribute-set"
    And the intercepted requests have resolved
    And the Onboarding PUT Organization Attribute Set "002" OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Onboarding GET Attribute Sets "005" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Configuration GET Attribute Set "002" request for Service Provider "001" has been intercepted
    And the User selects option with Cypress ID "mm-select-option-2f482486-3588-409c-a4a7-357ecaf426be" in the Select with Cypress ID "dialog-assign-organization-attribute-set select"
    And the User clicks on the Element with Cypress ID "dialog-assign-organization-attribute-set button-submit"
    And the intercepted requests have resolved
    And the Configuration GET User Attribute Sets "002" request for Service Provider "001" has been intercepted
    And the User clicks on the Element with Cypress ID "button-assign-user-attribute-set"
    And the intercepted requests have resolved
    And the Onboarding PUT User Attribute Set "002" OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Onboarding GET Attribute Sets "004" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Configuration GET Attribute Set "005" request for Service Provider "001" has been intercepted
    And the User selects option with Cypress ID "mm-select-option-2f482486-3588-409c-a4a7-357ecaf426be" in the Select with Cypress ID "dialog-assign-user-attribute-set select"
    When the User clicks on the Element with Cypress ID "dialog-assign-user-attribute-set button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-attribute-set row-0 name" contains the text as "Name #2"
    And the Element with Cypress ID "table-attribute-set row-0 description" contains the text as "Description #2"
    And the Element with Cypress ID "table-attribute-set row-0 type" contains the text as "Organization"
    And the Element with Cypress ID "table-attribute-set row-0 required_attribute_types" contains the text as "1"
    And the Element with Cypress ID "table-attribute-set row-0 optional_attribute_types" contains the text as "1"
    And the Element with Cypress ID "table-attribute-set row-1 name" contains the text as "Name #5"
    And the Element with Cypress ID "table-attribute-set row-1 description" contains the text as "Description #5"
    And the Element with Cypress ID "table-attribute-set row-1 type" contains the text as "User"
    And the Element with Cypress ID "table-attribute-set row-1 required_attribute_types" contains the text as "1"
    And the Element with Cypress ID "table-attribute-set row-1 optional_attribute_types" contains the text as "1"

  # TODO: We need to change the Configuration OAuth Client endpoint to include the Attribute Set data
  Scenario: Should unassign Attribute Sets from existing Application
    Given the User "003" is Signed In
    And the feature flag "attribute_sets" is enabled
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Onboarding GET Attribute Sets "003" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Configuration GET Attribute Set "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Attribute Set "004" request for Service Provider "001" has been intercepted
    And the Policies for OAuth Client request has been intercepted to return policies "001" for OAuth Client "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"
    And the intercepted requests have resolved
    And the Onboarding DELETE Organization Attribute Set from OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Onboarding GET Attribute Sets "002" for OAuthClient "001" for Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "tab-item-attribute-sets"
    And the User clicks on the Element with Cypress ID "table-attribute-set row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-1f482486-3588-409c-a4a7-357ecaf426be-item-remove-attribute-set"
    And the Element with Cypress ID "dialog-unassign-attribute-set dialog-subtitle" contains the text as "Are you sure you want to unassign attribute set Name #1 from application Auth Client 001?"
    And the User clicks on the Element with Cypress ID "dialog-unassign-attribute-set button-submit"
    And the intercepted requests have resolved
    And the Element with Cypress ID "table-attribute-set row-1" should NOT exist
    And the Element with Cypress ID "table-attribute-set row-0 name" contains the text as "Name #4"
    And the Element with Cypress ID "table-attribute-set row-0 description" contains the text as "Description #4"
    And the Element with Cypress ID "table-attribute-set row-0 type" contains the text as "User"
    And the Onboarding DELETE User Attribute Set from OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Onboarding GET Attribute Sets "000" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the User clicks on the Element with Cypress ID "table-attribute-set row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-9895eefc-6deb-4d5c-8421-b51af2945990-item-remove-attribute-set"
    And the User clicks on the Element with Cypress ID "dialog-unassign-attribute-set button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "table-attribute-set row-0" should NOT exist

  # TODO: We need to change the Configuration OAuth Client endpoint to include the Attribute Set data
  Scenario: Should remove and create Client Secret for existing Application
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the Onboarding GET Attribute Sets "000" for OAuthClient "001" for Service Provider "001" request has been intercepted
    And the Policies for OAuth Client request has been intercepted to return policies "001" for OAuth Client "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/applications/edf44f93-2b8f-4255-b7ed-23558fc46bee"
    And the intercepted requests have resolved
    And the Configuration DELETE OAuth Client Secret request has been intercepted to delete the Secret "002" for OAuth Client "001" and Service Provider "001"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001-one-secret" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-connection-configuration"
    And the User clicks on the Element with Cypress ID "button-edit"
    And the User clicks on the Element with Cypress ID "client-secret-ffd6b82d-9a04-4729-8270-89daee30b8c6 button-remove-client-secret"
    And the Element with Cypress ID "dialog-confirm-remove-client-secret dialog-title" contains the text as "Are you sure you want to delete this Client Secret for Auth Client 001?"
    And the User clicks on the Element with Cypress ID "dialog-confirm-remove-client-secret button-submit"
    And the intercepted requests have resolved
    And the Element with Cypress ID "client-secret-ffd6b82d-9a04-4729-8270-89daee30b8c5" contains the text as "18 Oct 2024 10:37"
    And the Element with Cypress ID "client-secret-ffd6b82d-9a04-4729-8270-89daee30b8c6" should NOT exist
    And the Configuration POST OAuth Client Secret request has been intercepted to create and return the Secret "001" for OAuth Client "001" and Service Provider "001"
    And the Configuration GET OAuth Client request has been intercepted to return the Oauth Client "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-generate-new-client-secret"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "dialog-secret-successfully-created dialog-title" contains the text as "Client Secret successfully created"
    And the Input inside Element with Cypress ID "dialog-secret-successfully-created input-application-client-secret-key" should have the value as "verysecretclientsecret"
    And the Element with Cypress ID "client-secrets client-secret-ffd6b82d-9a04-4729-8270-89daee30b8c5" contains the text as "18 Oct 2024 10:37"
    And the Element with Cypress ID "client-secrets client-secret-ffd6b82d-9a04-4729-8270-89daee30b8c6" contains the text as "19 Oct 2024 10:37"
