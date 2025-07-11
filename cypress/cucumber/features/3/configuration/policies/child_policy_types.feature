Feature: Service Provider - Child Policy Types

  Scenario: Should be able to add Child Policies Types to Policy Successfully
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "004" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-child-policies"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "add-child-policy-button"
    And the User clicks on the Element with Cypress ID "child-policy-type-ids-autocomplete autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "add-child-policy-type-dialog button-submit"
    And the Configuration Policy Types PUT request to add Child Policy Types to Policy Type "001" with Child Policy Types "003" and Service Provider "001" has been intercepted
    And the Update Policy request has been intercepted to return the Policy "001" for Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001-updated-child-policy-types" for Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "003" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "save-policy-type-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "child-policy-types row-0 name" contains the text as "Policy Type 003"
    And the Element with Cypress ID "child-policy-types row-0 description" contains the text as "Policy Type 003 Description"

  Scenario: Should be able to see no search results message
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return no Policy Types for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-child-policies"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "add-child-policy-button"
    And the Configuration GET Policy Types request has been intercepted to return no Policy Types for Service Provider "001"
    When the User clicks on the Element with Cypress ID "child-policy-type-ids-autocomplete autocomplete"
    And the User enters text "www.test.com" in Input inside Element with Cypress ID "child-policy-type-ids-autocomplete"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "autocomplete-empty-state" should exist

  Scenario: show table of child policy types
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "002" for Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "003" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-child-policies"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "child-policy-types" should exist
    And the Element with Cypress ID "child-policy-types" contains the text as "Policy Type 002"

  Scenario: redirect to policy type when clicking details
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "002" for Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "003" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-child-policies"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "actions-button-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6-item-go-to-policy-type-002"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"

  Scenario: Child policy usage should correctly redirect to parent
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "002" for Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "003" for Service Provider "001"
    And the Policies Usage request has been intercepted to return the Usage "001" for Policy "001" and Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-usage"
    And the User clicks on the Element with Cypress ID "policies-card"
    And the User clicks on the Element with Cypress ID "actions-button-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6-item-go-to-policy-001"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"

  Scenario: Should remove Child Policy Type
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "005" for Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "006" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-child-policies"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "actions-button-3fa85f64-5717-4562-b3fc-2c963f66a005"
    And the User clicks on the Element with Cypress ID "dropdown-3fa85f64-5717-4562-b3fc-2c963f66a005-item-remove-from-policy-type-006"
    And the User clicks on the Element with Cypress ID "button-confirm-delete-user"
    And the Element with Cypress ID "child-policy-types row-0" should NOT exist
    And the Update Policy request has been intercepted to return the Policy "006-no-child-policies" for Service Provider "001"
    And the Policies DELETE request to remove Child Policy Types from Policy "006" with Child Policy "005" and Service provider "001" has been intercepted
    And the Policy request has been intercepted to return the PolicyType "006-no-child-policies" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "save-policy-type-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "child-policy-types row-0" should NOT exist

  Scenario: Dialog for adding child policies should exist
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "002" for Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Policy Type request has been intercepted to return Policy Type "001" for Service Provider "001"
    And the Configuration GET Policy Type request has been intercepted to return Policy Type "002" for Service Provider "001"
    And the Configuration GET Policy Type request has been intercepted to return Policy Type "003" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-child-policies"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    When the User clicks on the Element with Cypress ID "add-child-policy-button"
    Then the Element with Cypress ID "add-child-policy-type-dialog" should exist

  Scenario: Child policies should be marked as Already Added
    Given the User "005" is Signed In
    And the IAM User @me request has been intercepted to return the User "005"
    And the Policy request has been intercepted to return the PolicyType "006" for Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "005" for Service Provider "001"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-child-policies"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "add-child-policy-button"
    And the User clicks on the Element with Cypress ID "child-policy-type-ids-autocomplete autocomplete"
    Then the Element with Cypress ID "badge-added" should exist
    And the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66a005" should have a class "mm-autocomplete-option--disabled"
