Feature: Service Provider - Resources - Resources Overview

  Scenario: Forbidden with non-service provider

    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/configuration"
    Then the Element with Cypress ID "tab-item-resources" should NOT exist
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Should show Resource Attributes

    Given the User "MMAdmin001" is Signed In
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001,002" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-resources"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "row-0 name" should have the text as "ResourceType Name 001"
    And the Element with Cypress ID "row-1 name" should have the text as "Resource Type 002"

  Scenario: Should enter edit mode on Resource Attribute details page from Resource Attributes overview page

    Given the User "MMAdmin001" is Signed In
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001,002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-resources"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "row-0 actions-323ff1a0-50de-4235-b509-6c2afde5078d"
    When the User clicks on the Element with Cypress ID "actions-dropdown-323ff1a0-50de-4235-b509-6c2afde5078d-item-edit"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/323ff1a0-50de-4235-b509-6c2afde5078d"
    And the Element with Cypress ID "button-save" should exist

  Scenario: Should delete Resource Attribute from Resource Attributes overview page

    Given the User "MMAdmin001" is Signed In
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001,002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-resources"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "row-1 actions-7a1f2c24-33f0-426e-8021-1a203ffb842b"
    And the User clicks on the Element with Cypress ID "actions-dropdown-7a1f2c24-33f0-426e-8021-1a203ffb842b-item-delete"
    And the Configuration DELETE Resource Type request has been intercepted to delete the Resource Type "002" for Service Provider "001"
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "delete-resource-submit-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "resources-table row-1" should NOT exist

  Scenario: Should create Resource Attribute from Resource Attributes overview page

    Given the User "MMAdmin001" is Signed In
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001,002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-resources"
    And the intercepted requests have resolved
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "create-resource-button"
    And the intercepted requests have resolved
    And the User types "ResourceType Name 001" in the Element with Cypress ID "input-resource-name"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the User selects option with Cypress ID "mm-select-option-323ff1a0-50de-4235-b509-6c2afde5078d" in the Select with Cypress ID "select-resource-attribute-0"
    And the Configuration POST Resource Type request has been intercepted to add the Resource Type "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/323ff1a0-50de-4235-b509-6c2afde5078d"

  Scenario: Should redirect to Resource Type Details page via click on Resource Type name

    Given the User "MMAdmin001" is Signed In
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001,002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-resources"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "row-0 name name-323ff1a0-50de-4235-b509-6c2afde5078d"
    Then the User should be redirected to "sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/323ff1a0-50de-4235-b509-6c2afde5078d"

  Scenario: Should redirect to Resource Type Details page via click on kebab menu

    Given the User "MMAdmin001" is Signed In
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Types request has been intercepted to return the Resource Types "001,002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-resources"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "row-0 actions-323ff1a0-50de-4235-b509-6c2afde5078d"
    When the User clicks on the Element with Cypress ID "actions-dropdown-323ff1a0-50de-4235-b509-6c2afde5078d-item-view"
    Then the User should be redirected to "sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/323ff1a0-50de-4235-b509-6c2afde5078d"