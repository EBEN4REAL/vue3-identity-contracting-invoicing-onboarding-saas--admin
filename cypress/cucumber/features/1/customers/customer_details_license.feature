Feature: Customers - Customer Details - License Tab

  Scenario: Should see tab with correct info displayed
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/customers"
    And the intercepted requests have resolved
    And the Element with Cypress ID "row-0" should be visible
    And the Element with Cypress ID "customers-table" should be visible
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Billing and Invoicing request has been intercepted to return the billing address "001" from Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the User clicks on the Element with Cypress ID "actions-dropdown-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the User force clicks on the Element with Cypress ID "actions-dropdown-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d-item-view-details"
    And the intercepted requests have resolved
    And the User should be redirected to "/sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the Licenses request has been intercepted to return for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" the Active Licenses "002" for service consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    When the User clicks on the Element with Cypress ID "licenses-expandable"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "allocate-license" should exist
    And the Element with Cypress ID "column-name-2fa85f64-5717-4562-b3fc-2c963f66afa6" should have the text as "License 2"
    And the Element with Cypress ID "column-description-2fa85f64-5717-4562-b3fc-2c963f66afa6" should have the text as "This is a test license"

  Scenario: Should be possible to Assign license correctly
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Billing and Invoicing request has been intercepted to return the billing address "001" from Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the User navigates to "/sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the intercepted requests have resolved
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the License and service consumer id "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d" and id "006"
    And the Licenses request has been intercepted to return for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" the Active Licenses "003" for service consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the User clicks on the Element with Cypress ID "licenses-expandable"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" the Active Licenses "001,002,003" for service consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001" for Service Provider "001" with query params "*"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "allocate-license"
    And the User clicks on the Element with Cypress ID "allocate-license-autocomplete autocomplete"
    And the intercepted requests have resolved
    And the User force clicks on the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to assign an agreement with id "3fa85f64-5717-4562-b3fc-2c963f66afa7" to an organization with id "001"
    And the Licenses request has been intercepted to return for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" the Active Licenses "002" for service consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    When the User clicks on the Element with Cypress ID "button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "column-name-2fa85f64-5717-4562-b3fc-2c963f66afa6" should have the text as "License 2"

  Scenario: Should only show tool tip message for disabled license without default policies
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Billing and Invoicing request has been intercepted to return the billing address "001" from Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the User navigates to "/sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the intercepted requests have resolved
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the License and service consumer id "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d" and id "006"
    And the Licenses request has been intercepted to return for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" the Active Licenses "003" for service consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the User clicks on the Element with Cypress ID "licenses-expandable"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" the Active Licenses "001,002,003" for service consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "*"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "allocate-license"
    And the User clicks on the Element with Cypress ID "allocate-license-autocomplete autocomplete"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa7" should have a class "mm-autocomplete-option--disabled"
    And the user hovers over the element with the Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Element with Cypress ID "tooltip" contains the text as "Can't allocate this license because there are no Default Policies attached"

  Scenario: Should be possible to Remove license correctly
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Billing and Invoicing request has been intercepted to return the billing address "001" from Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the User navigates to "/sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the intercepted requests have resolved
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the License and service consumer id "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d" and id "006"
    And the Licenses request has been intercepted to return for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" the Active Licenses "003" for service consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the User clicks on the Element with Cypress ID "licenses-expandable"
    And the intercepted requests have resolved
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to cancel the License with id "3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Licenses request has been intercepted to return for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" the Active Licenses "001" for service consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    When the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-cancel-license"
    And the User clicks on the Element with Cypress ID "button-submit"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "column-name-3fa85f64-5717-4562-b3fc-2c963f66afa6" should have the text as "ABC Group"
