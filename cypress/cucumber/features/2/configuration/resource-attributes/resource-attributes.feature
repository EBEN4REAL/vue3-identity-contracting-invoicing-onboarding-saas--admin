Feature: Service Provider - Resource Attributes - Resource Attributes Overview

  Scenario: Forbidden with non-service provider

    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/configuration"
    Then the Element with Cypress ID "tab-item-resource-attributes" should NOT exist
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Should show Resource Attributes Types

    Given the User "MMAdmin001" is Signed In
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002,005,006" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "row-0 name" should have the text as "Resource Attribute 001"
    And the Element with Cypress ID "row-0 format_option" should have the text as "Text"
    And the Element with Cypress ID "row-2 name" should have the text as "Resource Attribute 005"
    And the Element with Cypress ID "row-2 format_option" should have the text as "Yes/No"
    And the Element with Cypress ID "row-3 name" should have the text as "Resource Attribute 006"
    And the Element with Cypress ID "row-3 format_option" should have the text as "Datetime"

  Scenario: Should add Resource Attributes Type

    Given the User "MMAdmin001" is Signed In
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "create-resource-attribute-button"
    And the Element with Cypress ID "dialog-resource-attributes-create" should exist
    And the User types "Resource Attribute 003" in Input inside Element with Cypress ID "resource-attribute-input-0"
    And the User selects option with Cypress ID "mm-select-option-STRING" in the Select with Cypress ID "resource-attribute-select-0"
    And the Configuration POST Resource Attribute Type request has been intercepted to create the Resource Attribute Type for Service Provider "001"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002,003" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-submit"
    Then the Element with Cypress ID "row-2 name" should have the text as "Resource Attribute 003"
    And the Element with Cypress ID "row-2 format_option" should have the text as "Text"

  Scenario: Should show correct error message if resource attribute already exists

    Given the User "MMAdmin001" is Signed In
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "create-resource-attribute-button"
    And the Element with Cypress ID "dialog-resource-attributes-create" should exist
    And the Element with Cypress ID "resource-attribute-input-0 input" should exist
    And the Element with Cypress ID "resource-attribute-select-0" should exist
    And the User types "Resource Attribute 001" in Input inside Element with Cypress ID "resource-attribute-input-0"
    And the User selects option with Cypress ID "mm-select-option-STRING" in the Select with Cypress ID "resource-attribute-select-0"
    And the Configuration POST Resource Attribute Type request has been intercepted to return error 409 for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-submit"
    Then the Element with Cypress ID "mm-toast-text" contains the text as "Please enter a unique name"
    And the Element with Cypress ID "dialog-resource-attributes-create" should exist

  Scenario: Should update Resource Attributes Type

    Given the User "MMAdmin001" is Signed In
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "actions-dropdown-323ff1a0-50de-4235-b509-6c2afde5078d"
    And the User clicks on the Element with Cypress ID "actions-dropdown-323ff1a0-50de-4235-b509-6c2afde5078d-item-edit"
    And the User types "Resource Attribute 002" in Input inside Element with Cypress ID "resource-attribute-input-name"
    And the Configuration PATCH Resource Attribute Type request has been intercepted to update the Resource Attribute Type "Updated001" for Service Provider "001"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "Updated001,002,003" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "dialog-resource-attributes-create button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "dialog-resource-attributes-create" should NOT exist
    And the Element with Cypress ID "row-0 name" should have the text as "Resource Attribute 002"

  Scenario: Should delete Resource Attributes Type

    Given the User "MMAdmin001" is Signed In
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "actions-dropdown-7a1f2c24-33f0-426e-8021-1a203ffb842b"
    And the User clicks on the Element with Cypress ID "actions-dropdown-7a1f2c24-33f0-426e-8021-1a203ffb842b-item-delete"
    And the Configuration DELETE Resource Attribute Type request has been intercepted to delete the Resource Attribute Type "002" for Service Provider "001"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "dialog-resource-attribute-delete button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "dialog-resource-attributes-delete" should NOT exist
    And the Element with Cypress ID "resource-attributes-table row-1" should NOT exist

  Scenario: Should not delete Resource Attributes Type in use

    Given the User "MMAdmin001" is Signed In
    And the User navigates to "/sp/configuration"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,004" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "actions-dropdown-7a1f2c24-33f0-426e-8021-1a203ffb842c"
    Then the Element with Cypress ID "actions-dropdown-7a1f2c24-33f0-426e-8021-1a203ffb842c-item-delete" should have a class "mm-dropdown-item--disabled"
    And the Element with Cypress ID "actions-dropdown-7a1f2c24-33f0-426e-8021-1a203ffb842c-item-hint" should have the text as "You cannot delete this resource as there are active instances of it."
