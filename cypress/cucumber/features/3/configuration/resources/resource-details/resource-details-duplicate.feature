Feature: Service Provider - Resources - Duplicate

  Scenario: User should be redirected to the Create Resource page and Resource type data should be correct after clicking on Duplicate
    Given the User "MMAdmin001" is Signed In
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/323ff1a0-50de-4235-b509-6c2afde5078d"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "resource-type-header-dropdown button"
    When the User clicks on the Element with Cypress ID "resource-type-header-dropdown-item-duplicate"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/new"
    And the Element with Cypress ID "breadcrumbs breadcrumb" contains the text as "ResourceType Name 001"
    And the Element with Cypress ID "header-title" contains the text as "ResourceType Name 001"
    And the Element with Cypress ID "header-subtitle" contains the text as "ResourceType Description 001"
    And the Input inside Element with Cypress ID "input-resource-name" should have the value as "ResourceType Name 001"
    And the Textarea inside Element with Cypress ID "input-resource-description" should have the value as "ResourceType Description 001"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the Select with Cypress ID "select-resource-attribute-0" should have the value as "323ff1a0-50de-4235-b509-6c2afde5078d"
    And the Select with Cypress ID "select-resource-attribute-1" should have the value as "7a1f2c24-33f0-426e-8021-1a203ffb842b"
