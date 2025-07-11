Feature: Service Provider - Policy Type Filters

  Scenario: Should be able to add Filters to Policy Successfully
    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "005"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-filters"
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "add-filter-button"
    And the User clicks on the Element with Cypress ID "filter-ids-select autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-4d4e4900-3305-4d8a-b551-082c0d61658d"
    And the User clicks on the Element with Cypress ID "add-filter-submit-button"
    And the Update Policy request has been intercepted to return the Policy "001" for Service Provider "001"
    And the Policies POST request to add Filters to Policy "001" with Filter "005" and Service provider "001" has been intercepted
    When the User clicks on the Element with Cypress ID "save-policy-type-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "child-filters row-0 name" contains the text as "Filter A"

  Scenario: show table of filters

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "tab-item-filters"
    And the Element with Cypress ID "child-filters" should exist
    And the Element with Cypress ID "child-filters" contains the text as "Office Hours"

  Scenario: filters editable in edit mode

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "tab-item-filters"
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    Then the Element with Cypress ID "add-filter-button" should exist
    When the User clicks on the Element with Cypress ID "actions-button-e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    Then the Element with Cypress ID "dropdown-e418fd93-0d10-4c1e-b8e4-b29cddc456b0-item-remove-from-policy-type-001" should exist

  Scenario: redirect to filter when clicking details

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the User clicks on the Element with Cypress ID "tab-item-filters"
    And the User clicks on the Element with Cypress ID "actions-button-e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    When the User clicks on the Element with Cypress ID "dropdown-e418fd93-0d10-4c1e-b8e4-b29cddc456b0-item-go-to-office-hours"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"

  Scenario: show confirmation when clicking delete

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the User clicks on the Element with Cypress ID "tab-item-filters"
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "actions-button-e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    When the User clicks on the Element with Cypress ID "dropdown-e418fd93-0d10-4c1e-b8e4-b29cddc456b0-item-remove-from-policy-type-001"
    Then the Element with Cypress ID "confirm-remove-from-parent" should exist

  Scenario: Deleting the filter type should call the API

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the User clicks on the Element with Cypress ID "tab-item-filters"
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "actions-button-e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    When the User clicks on the Element with Cypress ID "dropdown-e418fd93-0d10-4c1e-b8e4-b29cddc456b0-item-remove-from-policy-type-001"
    When the User clicks on the Element with Cypress ID "button-confirm-remove-from-parent"
    Then the Update Policy request has been intercepted to update the PolicyType "002" for Service Provider "001"

  Scenario: Dialog for adding filters should exist

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the User clicks on the Element with Cypress ID "tab-item-filters"
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    When the User clicks on the Element with Cypress ID "add-filter-button"
    Then the Element with Cypress ID "add-filter-dialog" should exist

  Scenario: No options should exist

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch no Filters
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the User clicks on the Element with Cypress ID "tab-item-filters"
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    When the User clicks on the Element with Cypress ID "add-filter-button"
    And the User clicks on the Element with Cypress ID "filter-ids-select autocomplete"
    Then the Element with Cypress ID "autocomplete-no-options" should exist

  Scenario: Clicking on create button redirects to create filter

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the User clicks on the Element with Cypress ID "tab-item-filters"
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    When the User clicks on the Element with Cypress ID "add-filter-button"
    And the User clicks on the Element with Cypress ID "filter-ids-select autocomplete"
    #When the User clicks on the Element with Cypress ID "button-create-filter"
    #Then the User clicks on the Element with Cypress ID "button-switch-anyway"
    #Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"

  Scenario: Added Filters should be marked as added and should be disabled and show dialog

    Given the User "005" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Policy request has been intercepted to return the PolicyType "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "003"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "tab-item-filters"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-policy-type-button"
    And the User clicks on the Element with Cypress ID "add-filter-button"
    And the User clicks on the Element with Cypress ID "filter-ids-select autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-7a5ce69b-e174-42c7-86ab-25ece64ede30"
    And the User clicks on the Element with Cypress ID "add-filter-submit-button"
    And the User clicks on the Element with Cypress ID "add-filter-button"
    And the User clicks on the Element with Cypress ID "filter-ids-select autocomplete"
    Then the Element with Cypress ID "badge-added" should exist
    And the Element with Cypress ID "mm-autocomplete-option-7a5ce69b-e174-42c7-86ab-25ece64ede30" should have a class "mm-autocomplete-option--disabled"
