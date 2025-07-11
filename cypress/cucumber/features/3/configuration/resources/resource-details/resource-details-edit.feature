Feature: Service Provider - Resources - Edit

  Scenario: Resource Details should have correct values in Edit mode
    Given the User "MMAdmin001" is Signed In
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/323ff1a0-50de-4235-b509-6c2afde5078d"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "button-edit"
    Then the Input inside Element with Cypress ID "input-resource-name" should have the value as "ResourceType Name 001"
    And the Textarea inside Element with Cypress ID "input-resource-description" should have the value as "ResourceType Description 001"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    Then the Select with Cypress ID "select-resource-attribute-0" should have the value as "323ff1a0-50de-4235-b509-6c2afde5078d"
    And the Select with Cypress ID "select-resource-attribute-1" should have the value as "7a1f2c24-33f0-426e-8021-1a203ffb842b"

  Scenario: Resource Details should remain with old values after user edits and clicks Discard
    Given the User "MMAdmin001" is Signed In
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002,004" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/323ff1a0-50de-4235-b509-6c2afde5078d"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit"
    And the User types "ResourceType Name 001 Updated" in Input inside Element with Cypress ID "input-resource-name"
    And the User types "ResourceType Description 001 Updated" in Textarea inside Element with Cypress ID "input-resource-description"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the User selects option with Cypress ID "mm-select-option-7a1f2c24-33f0-426e-8021-1a203ffb842c" in the Select with Cypress ID "select-resource-attribute-0"
    When the User clicks on the Element with Cypress ID "button-discard"
    Then the User clicks on the Element with Cypress ID "confirm-discard-dialog button-confirm"
    And the User clicks on the Element with Cypress ID "tab-item-basic-information"
    And the Element with Cypress ID "mm-data-iterator name mm-data-iterator-item-text" contains the text as "ResourceType Name 001"
    And the Element with Cypress ID "mm-data-iterator description mm-data-iterator-item-text" contains the text as "ResourceType Description 001"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the Element with Cypress ID "resource-attribute-item-323ff1a0-50de-4235-b509-6c2afde5078d" contains the text as "Resource Attribute 001 (Text)"

  Scenario: Resource Details should be successfully updated
    Given the User "MMAdmin001" is Signed In
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,002,004" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/323ff1a0-50de-4235-b509-6c2afde5078d"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "button-edit"
    And the User types "ResourceType Name 001 Updated" in Input inside Element with Cypress ID "input-resource-name"
    And the User types "ResourceType Description 001 Updated" in Textarea inside Element with Cypress ID "input-resource-description"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the User clicks on the Element with Cypress ID "button-remove-resource-attribute-1"
    And the User selects option with Cypress ID "mm-select-option-7a1f2c24-33f0-426e-8021-1a203ffb842c" in the Select with Cypress ID "select-resource-attribute-0"
    And the Configuration PATCH Resource Type request has been intercepted to update the Resource Type "001" and return the Resource Type "001-Updated" for Service Provider "001"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001-Updated" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-save"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "tab-item-basic-information"
    Then the Element with Cypress ID "mm-data-iterator name mm-data-iterator-item-text" contains the text as "ResourceType Name 001"
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the Element with Cypress ID "mm-data-iterator description mm-data-iterator-item-text" contains the text as "ResourceType Description 001"
    And the Element with Cypress ID "resource-attribute-item-7a1f2c24-33f0-426e-8021-1a203ffb842c" contains the text as "Resource Attribute 004 (Text)"

  Scenario: Button Remove Resource Attribute Type should not exist if there is only one Resource Attribute Type
    Given the User "MMAdmin001" is Signed In
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Types request has been intercepted to return the Resource Attribute Types "001,003,006" for Service Provider "001"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/resources/323ff1a0-50de-4235-b509-6c2afde5078d"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-resource-attributes"
    And the User clicks on the Element with Cypress ID "button-edit"
    And the User clicks on the Element with Cypress ID "button-remove-resource-attribute-1"
    When the User clicks on the Element with Cypress ID "button-remove-resource-attribute-1"
    Then the Element with Cypress ID "button-remove-resource-attribute-0" should NOT exist
