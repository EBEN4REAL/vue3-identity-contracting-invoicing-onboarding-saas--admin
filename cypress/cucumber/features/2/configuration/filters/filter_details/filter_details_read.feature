Feature: Service Provider - Filter Details - Read

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/001"
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/001"
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Breadcrumb should have correct title and Usage tab should exist
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "breadcrumbs breadcrumb" contains the text as "Office Hours"
    And the Element with Cypress ID "tab-item-usage" should exist

  Scenario: Basic information tab should contain correct text
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-data-iterator name mm-data-iterator-item-text" contains the text as "Office Hours"
    And the Element with Cypress ID "mm-data-iterator description mm-data-iterator-item-text" contains the text as "Filter for Office Hours"

  Scenario: Filter conditions tab should contain correct text in Filter Conditions
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
    When the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    Then the Element with Cypress ID "filter-condition-0 select-filter-condition-attribute" contains the text as "Organization User Job Role"
    And the Element with Cypress ID "filter-condition-0 select-filter-condition-operator" contains the text as "Equal"
    And the Element with Cypress ID "filter-condition-0 select-filter-condition-value" contains the text as "Marketing"
    And the Element with Cypress ID "filter-condition-existing-0 filter-nested-name" contains the text as "Office Hours Nested"
    And the Element with Cypress ID "filter-condition-existing-0 badge" contains the text as "Existing"
    And the Element with Cypress ID "filter-condition-3 select-filter-condition-resource-type" contains the text as "ResourceType Name 001"
    And the Element with Cypress ID "filter-condition-3 select-filter-condition-resource-attribute-type" contains the text as "Resource Attribute 001"
    And the Element with Cypress ID "filter-condition-3 select-filter-condition-operator" contains the text as "Equal"
    And the Input with Cypress ID "filter-condition-3 input-filter-condition-value" should have value as "123"
    And the Element with Cypress ID "filter-condition-4 select-filter-condition-attribute" contains the text as "Resource operation"
    And the Element with Cypress ID "filter-condition-4 select-filter-condition-operator" contains the text as "Equal"
    And the Element with Cypress ID "filter-condition-4 select-filter-condition-value" contains the text as "Create"

  Scenario: Nested Filter button Go to Filter should redirect to Filter
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "002,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "002"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    When the User clicks on the Element with Cypress ID "filter-condition-existing-0 button-filter-nested-go-to-filter"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/7a5ce69b-e174-42c7-86ab-25ece64ede30"

  Scenario: Policy should have correct text in tab Usage
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "002,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "002"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "tab-item-usage"
    Then the Element with Cypress ID "table-policies row-0 name" contains the text as "Policy Name 001"
    And the Element with Cypress ID "table-policies row-0 description" contains the text as "Policy Description 001"

  Scenario: View Details button in Policy table should redirect to correct Policy Details page in tab Usage
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "002,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "002"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the Policy Types UX Behavior request has been intercepted to return the Policy Types UX Behavior for UX Category "001"
    And the Configuration GET Policy Type request has been intercepted to return Policy Type "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-usage"
    And the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6-item-view-details"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/policy-types/3fa85f64-5717-4562-b3fc-2c963f66afa6"

  Scenario: Parent Filter should have correct text in tab Usage
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "002,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "002"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "tab-item-usage"
    Then the Element with Cypress ID "table-filters row-0 name" contains the text as "Filter Name 004"
    And the Element with Cypress ID "table-filters row-0 description" contains the text as "Filter Description 004"

  Scenario: View Details button in Filter table should redirect to correct Filter Details page in tab Usage
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Filters request has been intercepted to return the Filters "002,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "002"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-usage"
    And the User clicks on the Element with Cypress ID "actions-7a5ce69b-e174-42c7-86ab-25ece64ede31"
    When the User clicks on the Element with Cypress ID "actions-dropdown-7a5ce69b-e174-42c7-86ab-25ece64ede31-item-view-details"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/7a5ce69b-e174-42c7-86ab-25ece64ede31"
