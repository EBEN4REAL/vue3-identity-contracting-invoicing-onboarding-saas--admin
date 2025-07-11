Feature: Configuration - Policy Types

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/configuration"
    Then the Element with Cypress ID "policies-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/configuration"
    Then the Element with Cypress ID "policies-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Should show correct Policy Types data
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the Policy Types UX Categories request has been intercepted to return the Policy Types UX Categories
    When the User clicks on the Element with Cypress ID "tab-item-policies"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "policies-table row-0 name" should have the text as "Policy 1"
    And the Element with Cypress ID "policies-table row-0 description" should have the text as "Policy 1 description"

  Scenario: Should redirect to Policy Type details via click on name
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "003" for Service Provider "001"
    And the Policy Types UX Categories request has been intercepted to return the Policy Types UX Categories
    And the User clicks on the Element with Cypress ID "tab-item-policies"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Policy Type request has been intercepted to return Policy Type "003" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "policies-table row-0 name column-name-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa7"

  Scenario: Should redirect to Policy Type details via click on kebab menu
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "003" for Service Provider "001"
    And the Policy Types UX Categories request has been intercepted to return the Policy Types UX Categories
    And the User clicks on the Element with Cypress ID "tab-item-policies"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Policy Type request has been intercepted to return Policy Type "003" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "policies-table row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-view"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa7"

  Scenario: Should be possible to go to Edit view from overview
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "003" for Service Provider "001"
    And the Policy Types UX Categories request has been intercepted to return the Policy Types UX Categories
    And the User clicks on the Element with Cypress ID "tab-item-policies"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Policy Type request has been intercepted to return Policy Type "003" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "policies-table row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-edit"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa7?editMode=true"

  Scenario: Should not be possible to delete a policy if there is active instances
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "002" for Service Provider "001"
    And the Policy Types UX Categories request has been intercepted to return the Policy Types UX Categories
    And the User clicks on the Element with Cypress ID "tab-item-policies"
    And the intercepted requests have resolved
    And the Element with Cypress ID "policies-table" should be visible
    And the Element with Cypress ID "column-name-3fa85f64-5717-4562-b3fc-2c963f66afa5" should have the text as "Policy 2"
    When the User clicks on the Element with Cypress ID "actions"
    Then the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa5-item-delete" should have a class "mm-dropdown-item--disabled"
    And the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa5-item-hint" should have the text as "You cannot delete this policy as there are active instances of it."

  Scenario: Should delete Policy Type
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "003" for Service Provider "001"
    And the Policy Types UX Categories request has been intercepted to return the Policy Types UX Categories
    And the User clicks on the Element with Cypress ID "tab-item-policies"
    And the intercepted requests have resolved
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to delete the Policy with id "3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-delete"
    And the Element with Cypress ID "dialog-title" should have the text as "Delete Policy 3"
    When the User force clicks on the Element with Cypress ID "button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7" should NOT exist
