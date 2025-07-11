Feature: Service Provider - Policy Types

  Scenario: Forbidden with non-Org User

    Given the User "001OnboardingCompleted" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP

    Given the User "002" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Success with SP Admin from direct URL

    Given the User "003" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Element with Cypress ID "header-title" should have the text as "Policy Type 001"
    And the Element with Cypress ID "header-subtitle" should have the text as "Policy Type 001 Description"

  Scenario: Success with SP Editor from direct URL

    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Element with Cypress ID "header-title" should have the text as "Policy Type 001"
    And the Element with Cypress ID "header-subtitle" should have the text as "Policy Type 001 Description"

  Scenario: Success with SP Viewer from direct URL

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Element with Cypress ID "header-title" should have the text as "Policy Type 001"
    And the Element with Cypress ID "header-subtitle" should have the text as "Policy Type 001 Description"

  Scenario: open confirm delete modal

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the User clicks on the Element with Cypress ID "policy-type-dropdown button"
    When the User clicks on the Element with Cypress ID "policy-type-dropdown-item-delete"
    Then the Element with Cypress ID "confirm-delete-policy-type" should be visible

  Scenario: delete policy type redirects to configuration policies and the policies tab is active

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "policy-type-dropdown button"
    And the User clicks on the Element with Cypress ID "policy-type-dropdown-item-delete"
    And the Delete Policy "001" for Service Provider "001" request has been intercepted
    When the User clicks on the Element with Cypress ID "button-confirm-delete-policy-type"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/configuration"
    And the Element with Cypress ID "tab-item-policies" should have a class "mm-tabs-item--active"

  Scenario: delete policy should not be possible if there are active instances

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "004" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66a004"
    And the User clicks on the Element with Cypress ID "policy-type-dropdown button"
    Then the Element with Cypress ID "policy-type-dropdown-item-delete" should have a class "mm-dropdown-item--disabled"
    And the Element with Cypress ID "policy-type-dropdown-item-hint" should have the text as "You cannot delete this policy as there are active instances of it."
