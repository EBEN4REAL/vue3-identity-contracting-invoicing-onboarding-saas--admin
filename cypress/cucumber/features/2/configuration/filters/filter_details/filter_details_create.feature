Feature: Service Provider - Filter Details - Create

  Scenario: Button Save filter should exist and Usage tab should not exist
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    Then the Element with Cypress ID "button-save-filter" should exist
    Then the Element with Cypress ID "tab-item-usage" should NOT exist

  Scenario: Breadcrumb should have correct title when empty filter data
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    Then the Element with Cypress ID "breadcrumbs breadcrumb" contains the text as "New Filter"

  Scenario: Header Title should have correct text when empty filter data
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    Then the Element with Cypress ID "header-title" contains the text as "New Filter"

  Scenario: Breadcrumb should have correct title when user fills Filter name field
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    When the User types "Office Hours" in Input inside Element with Cypress ID "input-filter-name"
    Then the Element with Cypress ID "breadcrumbs breadcrumb" contains the text as "Office Hours"

  Scenario: Header Title should have correct text when user fills Filter name field
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    When the User types "Office Hours" in Input inside Element with Cypress ID "input-filter-name"
    Then the Element with Cypress ID "header-title" contains the text as "Office Hours"

  Scenario: Header Subtitle should have correct text when user fills Filter description field
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    When the User types "Office Hours Description" in Textarea inside Element with Cypress ID "input-filter-description"
    Then the Element with Cypress ID "header-subtitle" contains the text as "Office Hours Description"

  Scenario: User should successfully create filter with single condition
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    And the User types "Office Hours" in Input inside Element with Cypress ID "input-filter-name"
    And the User types "Filter for Office Hours" in Textarea inside Element with Cypress ID "input-filter-description"
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    And the User selects option with Cypress ID "mm-select-option-ORGANIZATION_USER__job_role" in the Select with Cypress ID "filter-condition-0 select-filter-condition-attribute"
    And the User selects option with Cypress ID "mm-select-option-NOT_EQUAL" in the Select with Cypress ID "filter-condition-0 select-filter-condition-operator"
    And the User selects option with Cypress ID "mm-select-option-MARKETING" in the Select with Cypress ID "select-filter-condition-value"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to create the Filter with id "001"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"

  Scenario: User should successfully create filter with multiple conditions and comparison operator OR
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    And the User types "Office Hours" in Input inside Element with Cypress ID "input-filter-name"
    And the User types "Filter for Office Hours" in Textarea inside Element with Cypress ID "input-filter-description"
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    And the User selects option with Cypress ID "mm-select-option-ORGANIZATION_USER__job_role" in the Select with Cypress ID "filter-condition-0 select-filter-condition-attribute"
    And the User selects option with Cypress ID "mm-select-option-NOT_EQUAL" in the Select with Cypress ID "filter-condition-0 select-filter-condition-operator"
    And the User selects option with Cypress ID "mm-select-option-MARKETING" in the Select with Cypress ID "select-filter-condition-value"
    And the User clicks on the Element with Cypress ID "button-add-filter-condition"
    And the User selects option with Cypress ID "mm-select-option-ORGANIZATION_USER__email" in the Select with Cypress ID "filter-condition-1 select-filter-condition-attribute"
    And the User selects option with Cypress ID "mm-select-option-NOT_EQUAL" in the Select with Cypress ID "filter-condition-1 select-filter-condition-operator"
    And the User types "email@mail.com" in Input inside Element with Cypress ID "filter-condition-1 input-filter-condition-value"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to create the Filter with id "001"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"

  Scenario: Tab should be switched to the one with error fields
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    And the User types "Office Hours" in Input inside Element with Cypress ID "input-filter-name"
    And the User types "Filter for Office Hours" in Textarea inside Element with Cypress ID "input-filter-description"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    Then the Element with Cypress ID "tab-item-filter-conditions" should have a class "mm-tabs-item--active"

  Scenario: Tab should be switched to the first one with error fields even if other tabs have errors
    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    And the User types "Filter for Office Hours" in Textarea inside Element with Cypress ID "input-filter-description"
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    Then the Element with Cypress ID "tab-item-basic-information" should have a class "mm-tabs-item--active"

  Scenario: Show UnsavedChanges Modal When Leave Page Without Saving

    Given the User "004" is Signed In
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    And the User types "Office Hours" in Input inside Element with Cypress ID "input-filter-name"
    And the User types "Filter for Office Hours" in Textarea inside Element with Cypress ID "input-filter-description"
    When the User clicks on the Element with Cypress ID "breadcrumb-link"
    Then the Element with Cypress ID "dialog-unsaved-changes" should exist
    