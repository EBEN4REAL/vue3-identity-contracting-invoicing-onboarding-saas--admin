Feature: Service Provider - Allocated License Details

  Scenario: Should be possible to go to license details page with correct info
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Licenses request has been intercepted to return the Licenses "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User navigates to "/sp/access-control/access-license#allocated_licenses"
    And the intercepted requests have resolved
    And the billing request has been intercepted to return the agreement with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Licenses request has been intercepted to return the License "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Element with Cypress ID "actions-dropdown-4a6f01d0-f3c6-4923-ad98-112d6d97355b-item-view-license" should be visible
    And the User force clicks on the Element with Cypress ID "actions-dropdown-4a6f01d0-f3c6-4923-ad98-112d6d97355b-item-view-license"
    And the intercepted requests have resolved
    Then the User should be redirected to "sp/access-control/access-license/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Element with Cypress ID "header-title" contains the text as "License 3 for Acme Inc. SP"
    And the Element with Cypress ID "organization-name" contains the text as "Acme Inc. SP"
    And the Element with Cypress ID "effective-from" contains the text as "28 Mar 2024"
    And the Element with Cypress ID "effective-to" should NOT exist
    And the Element with Cypress ID "pricing-model" should NOT exist
    And the Element with Cypress ID "price" should NOT exist
    And the Element with Cypress ID "billing-period" should NOT exist
    And the Element with Cypress ID "next-billing-date" should NOT exist

  Scenario: Should be possible to go to license details page with correct info when license is Cancelled
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Licenses request has been intercepted to return the Licenses "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User navigates to "/sp/access-control/access-license#allocated_licenses"
    And the intercepted requests have resolved
    And the billing request has been intercepted to return the agreement with id "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Licenses request has been intercepted to return the License "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "actions-2fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Element with Cypress ID "actions-dropdown-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d-item-view-license" should be visible
    And the User force clicks on the Element with Cypress ID "actions-dropdown-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d-item-view-license"
    And the intercepted requests have resolved
    Then the User should be redirected to "sp/access-control/access-license/2fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Element with Cypress ID "header-title" contains the text as "License 2 for Acme Inc. SP"
    And the Element with Cypress ID "badge" contains the text as "Cancelled"
    And the Element with Cypress ID "effective-to" should be visible
    And the Element with Cypress ID "price" should NOT exist

  Scenario: Should be possible to go to customer details page when clicking on customer
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Licenses request has been intercepted to return the Licenses "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User navigates to "/sp/access-control/access-license#allocated_licenses"
    And the intercepted requests have resolved
    And the billing request has been intercepted to return the agreement with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Element with Cypress ID "actions-dropdown-4a6f01d0-f3c6-4923-ad98-112d6d97355b-item-view-license" should be visible
    And the User force clicks on the Element with Cypress ID "actions-dropdown-4a6f01d0-f3c6-4923-ad98-112d6d97355b-item-view-license"
    And the intercepted requests have resolved
    And the User should be redirected to "sp/access-control/access-license/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Billing and Invoicing request has been intercepted to return the billing address "001" from Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    When the User clicks on the Element with Cypress ID "organization-name"
    And the intercepted requests have resolved
    Then the User should be redirected to "sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"

  Scenario: Payments and Invoice tables should not exist and Legal Docs should be populated
    Given the User "003" is Signed In
    And the feature flag "billing_and_invoicing" is enabled
    And the feature flag "license_details_page" is enabled
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User navigates to "/sp/access-control/access-license"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the Licenses "003,006" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" with query params "category=ACCESS&limit=10&offset=0&sort=effective_from_date:desc"
    And the User clicks on the Element with Cypress ID "tab-item-allocated-licenses"
    And the intercepted requests have resolved
    And the billing request has been intercepted to return the agreement with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Licenses request has been intercepted to return the License "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Element with Cypress ID "actions-dropdown-4a6f01d0-f3c6-4923-ad98-112d6d97355b-item-view-license" should be visible
    And the User force clicks on the Element with Cypress ID "actions-dropdown-4a6f01d0-f3c6-4923-ad98-112d6d97355b-item-view-license"
    And the intercepted requests have resolved
    And the User should be redirected to "sp/access-control/access-license/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Element with Cypress ID "payments-expandable" should NOT exist
    And the Element with Cypress ID "invoices-expandable" should NOT exist
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "001" for for Service Provider "001"
    And the Configuration GET Legal Document Type PDF request has been intercepted to return the Legal Document Type "001" PDF URL for Service Provider "001"
    When the User clicks on the Element with Cypress ID "legal-docs-expandable"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "row-0 name" should have the text as "doc name"
