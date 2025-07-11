Feature: Service Provider - Resource Details - Read

  Scenario: Should contain correct data
    Given the User "MMAdmin001" is Signed In
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002" for Service Provider "001"
    When the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/323ff1a0-50de-4235-b509-6c2afde5078d"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "breadcrumbs breadcrumb" contains the text as "ResourceType Name 001"
    And the Element with Cypress ID "header-title" contains the text as "ResourceType Name 001"
    And the Element with Cypress ID "header-subtitle" contains the text as "ResourceType Description 001"
    And the Element with Cypress ID "mm-data-iterator name mm-data-iterator-item-text" contains the text as "ResourceType Name 001"
    And the Element with Cypress ID "mm-data-iterator description mm-data-iterator-item-text" contains the text as "ResourceType Description 001"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the Element with Cypress ID "resource-attribute-item-323ff1a0-50de-4235-b509-6c2afde5078d" contains the text as "Resource Attribute 001 (Text)"
    And the Element with Cypress ID "resource-attribute-item-7a1f2c24-33f0-426e-8021-1a203ffb842b" contains the text as "Resource Attribute 002 (Text)"