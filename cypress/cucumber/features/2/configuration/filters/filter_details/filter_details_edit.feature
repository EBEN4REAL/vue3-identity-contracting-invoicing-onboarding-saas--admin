Feature: Service Provider - Filter Details - Edit

  Scenario: Basic information tab should be updated
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "002" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-edit-filter"
    And the intercepted requests have resolved
    And the User types "NEW Office Hours" in Input inside Element with Cypress ID "input-filter-name"
    And the User types "NEW Filter for Office Hours" in Textarea inside Element with Cypress ID "input-filter-description"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to update the Filter with id "001-Updated"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "002" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-data-iterator name mm-data-iterator-item-text" contains the text as "NEW Office Hours"
    And the Element with Cypress ID "mm-data-iterator description mm-data-iterator-item-text" contains the text as "NEW Filter for Office Hours"

  Scenario: Filter condition tab Filter condition should be updated
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "002" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-edit-filter"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    And the User selects option with Cypress ID "mm-select-option-ORGANIZATION_USER__email" in the Select with Cypress ID "filter-condition-0 select-filter-condition-attribute"
    And the User selects option with Cypress ID "mm-select-option-NOT_EQUAL" in the Select with Cypress ID "filter-condition-0 select-filter-condition-operator"
    And the User types "email@mail.com" in Input inside Element with Cypress ID "filter-condition-0 input-filter-condition-value"
    And the User selects option with Cypress ID "mm-select-option-323ff1a0-50de-4235-b509-6c2afde5078d" in the Select with Cypress ID "filter-condition-3 select-resource-type"
    And the User selects option with Cypress ID "mm-select-option-323ff1a0-50de-4235-b509-6c2afde5078d" in the Select with Cypress ID "filter-condition-3 select-resource-attribute-type"
    And the User selects option with Cypress ID "mm-select-option-NOT_EQUAL" in the Select with Cypress ID "filter-condition-3 select-filter-condition-operator"
    And the User types "NEW 123" in Input inside Element with Cypress ID "filter-condition-3 input-filter-condition-value"
    And the User selects option with Cypress ID "mm-select-option-NOT_EQUAL" in the Select with Cypress ID "filter-condition-4 select-filter-condition-operator"
    And the User selects option with Cypress ID "mm-select-option-update" in the Select with Cypress ID "filter-condition-4 select-filter-condition-value"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to update the Filter with id "001-Updated"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "002" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    And the intercepted requests have resolved
    Then the Select with Cypress ID "filter-condition-0 select-filter-condition-attribute" should have the value as "ORGANIZATION_USER__email"
    And the Select with Cypress ID "filter-condition-0 select-filter-condition-operator" should have the value as "NOT_EQUAL"
    And the Input with Cypress ID "filter-condition-0 input-filter-condition-value" should have value as "email@mail.com"
    And the Select with Cypress ID "filter-condition-2 select-filter-condition-resource-type" should have the value as "7a1f2c24-33f0-426e-8021-1a203ffb842b"
    And the Select with Cypress ID "filter-condition-2 select-filter-condition-resource-attribute-type" should have the value as "7a1f2c24-33f0-426e-8021-1a203ffb842b"
    And the Select with Cypress ID "filter-condition-2 select-filter-condition-operator" should have the value as "NOT_EQUAL"
    And the Element with Cypress ID "filter-condition-3 select-filter-condition-attribute" contains the text as "Resource operation"
    And the Element with Cypress ID "filter-condition-3 select-filter-condition-operator" contains the text as "Not Equal"
    And the Element with Cypress ID "filter-condition-3 select-filter-condition-value" contains the text as "Update"

  Scenario: Filter condition tab Filter condition comparison operator should be updated
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "002" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-edit-filter"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    And the User clicks on the Element with Cypress ID "mm-toggle-item-OR"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to update the Filter with id "001-Updated"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "002" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "filter-condition-comparison-operator" contains the text as "OR"

  Scenario: Filter condition tab Filter condition should be removed
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "006"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "006"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/4d4e4900-3305-4d8a-b551-082c0d61658d"
    And the intercepted requests have resolved
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-edit-filter"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    And the User clicks on the Element with Cypress ID "filter-condition-0 button-remove-filter-condition"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to update the Filter with id "006-Updated"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "filter-condition-1" should NOT exist

  Scenario: Tab should be switched to the one that contains field with error
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "002" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-edit-filter"
    And the intercepted requests have resolved
    And the User clears the Input inside Element with Cypress ID "input-filter-name"
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    Then the Element with Cypress ID "tabs tab-item-basic-information" should have a class "mm-tabs-item--active"
    And the Form Element "input" with Cypress ID "input-filter-name" should have a Form Error for validator "required"

  Scenario: Filter conditions tab should have Nested Filters
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "002" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-edit-filter"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    Then the Element with Cypress ID "filter-condition-existing-0" should exist

  Scenario: Nested Filter should have proper text in Filter conditions tab
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "002" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-edit-filter"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    Then the Element with Cypress ID "filter-condition-existing-0 filter-nested-name" contains the text as "Office Hours Nested"
    And the Element with Cypress ID "filter-condition-existing-0 filter-nested-description" contains the text as "About Office Hours Nested"

  Scenario: Nested Filter button Go to Filter should redirect to Filter
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "002" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    And the User clicks on the Element with Cypress ID "button-edit-filter"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "filter-condition-existing-0 button-filter-nested-go-to-filter"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/7a5ce69b-e174-42c7-86ab-25ece64ede30"

  Scenario: Nested Filter button Remove should remove Nested Filter
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "002" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    And the User clicks on the Element with Cypress ID "button-edit-filter"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "filter-condition-existing-1 button-filter-nested-remove"
    And the Element with Cypress ID "filter-condition-existing-1" should NOT exist
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to update the Filter with id "001-Updated"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "002" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "filter-condition-existing-1" should NOT exist

  Scenario: Add Existing Filter dialog should exist
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "002" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    And the User clicks on the Element with Cypress ID "button-edit-filter"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "button-import-existing-filter"
    Then the Element with Cypress ID "dialog-add-existing-filter" should exist

  Scenario: Filter should be updated after user adds Existing Filter via Add Existing Filter dialog
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "002"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "002"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001" for Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "004"
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    And the User clicks on the Element with Cypress ID "button-edit-filter"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-import-existing-filter"
    And the User clicks on the Element with Cypress ID "dialog-add-existing-filter autocomplete"
    And the User clicks on the Element with Cypress ID "dialog-add-existing-filter autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-7a5ce69b-e174-42c7-86ab-25ece64ede31"
    And the User clicks on the Element with Cypress ID "button-submit-add-existing-filter"
    And the Element with Cypress ID "filter-condition-existing-1" should exist
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to update the Filter with id "002-Updated-Nested"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "filter-condition-existing-1" should exist

  Scenario: Should not be possible to delete a filter if there is active instances
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "002"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "002"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "button"
    Then the Element with Cypress ID "filter-header-dropdown-item-delete" should have a class "mm-dropdown-item--disabled"
    And the Element with Cypress ID "filter-header-dropdown-item-hint" should have the text as "You cannot delete this filter as there are active instances of it."
