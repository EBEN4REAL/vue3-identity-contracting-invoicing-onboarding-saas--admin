Feature: Service Provider - Licenses - Allocate License

  Scenario: Allocate license page should be visible with correct info
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Licenses request has been intercepted to return the Licenses "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" with query params "category=ACCESS&limit=10&offset=0&sort=effective_from_date:desc"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User navigates to "/sp/access-control/access-license#allocated_licenses"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "limit=50&offset=0&category=ACCESS"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-open-licenses"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "header-title" should have the text as "Allocate License"
    And the Element with Cypress ID "customer-search" should exist
    And the Element with Cypress ID "confirm-button" should exist
    And the Element with Cypress ID "cancel-button" should exist

  Scenario: Allocate license canceled
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Licenses request has been intercepted to return the Licenses "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User navigates to "/sp/access-control/access-license#allocated_licenses"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "limit=50&offset=0&category=ACCESS"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-open-licenses"
    And the User clicks on the Element with Cypress ID "cancel-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "access-control-allocated-licenses-table" should be visible

  Scenario: Error message should appear in case we don't have options selected
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Licenses request has been intercepted to return the Licenses "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User navigates to "/sp/access-control/access-license#allocated_licenses"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "limit=50&offset=0&category=ACCESS"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-open-licenses"
    And the User clicks on the Element with Cypress ID "confirm-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-autocomplete-error-required-text" should exist

  Scenario: License with no default policies should be disabled
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "limit=50&offset=0&category=ACCESS"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User navigates to "/sp/access-control/access-license/allocate-license"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the Licenses "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User force clicks on the Element with Cypress ID "customer-search autocomplete"
    And the User force clicks on the Element with Cypress ID "customer-search mm-autocomplete-option-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the Element with Cypress ID "select-license" should exist
    When the User clicks on the Element with Cypress ID "select-license autocomplete"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa7" should exist
    And the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa7" should have a class "mm-autocomplete-option--disabled"

  Scenario: Should allocate license correctly
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Licenses request has been intercepted to return the Licenses "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User navigates to "/sp/access-control/access-license#allocated_licenses"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001" for Service Provider "001" with query params "limit=50&offset=0&category=ACCESS"
    And the User clicks on the Element with Cypress ID "button-open-licenses"
    And the intercepted requests have resolved
    When the User force clicks on the Element with Cypress ID "customer-search autocomplete"
    And the User force clicks on the Element with Cypress ID "customer-search mm-autocomplete-option-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the User clicks on the Element with Cypress ID "select-license autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to assign an agreement with id "3fa85f64-5717-4562-b3fc-2c963f66afa7" to an organization with id "001"
    And the Licenses request has been intercepted to return the Licenses "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "confirm-button"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/access-control/access-license#allocated_licenses"
    And the Element with Cypress ID "service_consumer_name" should have the text as "Org 003"
    And the Element with Cypress ID "agreement_name" should have the text as "License 3"
    And the Element with Cypress ID "effective_from_date" should have the text as "28 Mar 2024"
    And the Element with Cypress ID "valid_until" should have the text as "-"
    And the Element with Cypress ID "cancelled" should have the text as "Active"

  Scenario: Should be possible to select customer see license and clear customer selected
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Licenses request has been intercepted to return the Licenses "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User navigates to "/sp/access-control/access-license#allocated_licenses"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for Autocomplete
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001" for Service Provider "001" with query params "limit=50&offset=0&category=ACCESS"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-open-licenses"
    And the intercepted requests have resolved
    And the User should be redirected to "/sp/access-control/access-license/allocate-license?category=access"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "customer-search autocomplete"
    And the User clicks on the Element with Cypress ID "customer-search mm-autocomplete-option-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the User clicks on the Element with Cypress ID "select-license autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User force clicks on the Element with Cypress ID "customer-search clear-button"
    Then the Element with Cypress ID "select-license" should NOT exist
    And the Input inside Element with Cypress ID "customer-search" should have the value as ""
