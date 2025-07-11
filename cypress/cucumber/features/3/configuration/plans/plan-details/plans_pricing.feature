Feature: Service Provider - Plan Details - Read

  Scenario: Plan pricing should NOT be visible when feature flag is disabled
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the feature flag "billing_and_invoicing" is disabled
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    When the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "tab-item-pricing" should NOT exist

  Scenario: Should add default pricing successfully
    Given the User "004" is Signed In
    And the feature flag "billing_and_invoicing" is enabled
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the User clicks on the Element with Cypress ID "button-create-plan"
    And the intercepted requests have resolved
    And the User types "Agreement Type 003 External" in Input inside Element with Cypress ID "input-license-external-name"
    And the User types "Agreement Type 003" in Input inside Element with Cypress ID "input-license-name"
    And the User types "Agreement Type 003 Description" in Textarea inside Element with Cypress ID "input-license-description"
    And the User types "Agreement Type 003 Description External" in Textarea inside Element with Cypress ID "input-license-external-description"
    And the User clicks on the Element with Cypress ID "tabs tab-item-policies"
    And the User clicks on the Element with Cypress ID "button-open-dialog-add-default-policies"
    And the User clicks on the Element with Cypress ID "autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-001"
    And the User clicks on the Element with Cypress ID "button-submit-add-default-policies"
    And the Configuration POST Agreement Types request has been intercepted to create Agreement Type "003_WithDefaultPolicy001AndPriceFree" for Service Provider "001"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithDefaultPolicy001AndPriceFree" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Billing and Invoicing request has been intercepted to update and return the Agreement Type "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Billing and Invoicing request has been intercepted to return the Agreement Type "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "button-save-license"
    And the intercepted requests have resolved
    Then the User clicks on the Element with Cypress ID "tab-item-pricing"
    And the Element with Cypress ID "row-0 billing_type" should have the text as "Free"

    Scenario: Should edit pricing successfully
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_WithDefaultPolicy001AndPriceFree" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the Billing and Invoicing request has been intercepted to return the Agreement Type "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-pricing"
    And the Element with Cypress ID "row-0 billing_type" should have the text as "Free"
    And the User clicks on the Element with Cypress ID "button-edit-license"
    And the User clicks on the Element with Cypress ID "row-0 edit-pricing-button"
    And the User selects option with Cypress ID "mm-select-option-ONCE_OFF" in the Select with Cypress ID "select-billing-type"
    And the User types "200" in the Element with Cypress ID "billing-price"
    And the User types "Test description" in Textarea inside Element with Cypress ID "billing-description"
    And the User clicks on the Element with Cypress ID "button-submit"
    And the Configuration PATCH Agreement Type request has been intercepted to update Agreement Type "003_WithDefaultPolicy001AndPriceFree" and return Agreement Type "003_WithDefaultPolicy001AndPriceOnceOff200" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-save-license"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "tab-item-pricing"
    Then the Element with Cypress ID "row-0 billing_type" should have the text as "Once-off"
