Feature: Service Provider - Resource Details - Delete

  Scenario: Should delete Resource type
    Given the User "MMAdmin001" is Signed In
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/323ff1a0-50de-4235-b509-6c2afde5078d"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "resource-type-header-dropdown button"
    And the User clicks on the Element with Cypress ID "resource-type-header-dropdown-item-delete"
    And the Element with Cypress ID "dialog-delete-resource-type dialog-title" contains the text as "Delete resource ResourceType Name 001"
    And the Configuration DELETE Resource Type request has been intercepted to delete the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "dialog-delete-resource-type delete-resource-submit-button"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/config"
    And the Element with Cypress ID "tab-item-resources" should have a class "mm-tabs-item--active"
    And the Element with Cypress ID "resources-table row-0" should NOT exist
