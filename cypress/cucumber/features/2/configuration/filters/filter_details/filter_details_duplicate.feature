Feature: Configuration - Filters - Duplicate

  Scenario: Redirect to the New Filter page after user clicks on Duplicate
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
    And the User clicks on the Element with Cypress ID "filter-header-dropdown button"
    And the User clicks on the Element with Cypress ID "filter-header-dropdown-item-duplicate"
    And the intercepted requests have resolved
    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    And the Input with Cypress ID "input-filter-name" should have value as "Office Hours"
    And the Textarea with Cypress ID "input-filter-description" should have value as "Filter for Office Hours"
    When the User clicks on the Element with Cypress ID "tab-item-filter-conditions"
    Then the Element with Cypress ID "mm-toggle-item-AND" should have a class "mm-toggle-item--active"
    And the Element with Cypress ID "filter-condition-0 select-filter-condition-attribute" contains the text as "Organization User Job Role"
    And the Element with Cypress ID "filter-condition-0 select-filter-condition-operator" contains the text as "Equal"
    And the Element with Cypress ID "filter-condition-0 select-filter-condition-value" contains the text as "Marketing"
    And the Element with Cypress ID "filter-condition-existing-0" should exist
