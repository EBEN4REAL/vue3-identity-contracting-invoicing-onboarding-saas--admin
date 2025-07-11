Feature: Access Control - Organizations

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/access-control/organizations"
    Then the Element with Cypress ID "organizations-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/access-control/organizations"
    Then the Element with Cypress ID "organizations-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario Outline: Success from direct URL
    Given the User "<user>" is Signed In
    And the IAM User @me request has been intercepted to return the User "<user>"
    And the IAM Service Providers request has been intercepted to return the Organizations "001,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/access-control/organizations"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "organizations-table" should be visible
    And the Element with Cypress ID "row-0 name" should have the text as "Acme Inc. SP"

    Examples: Users
      | user |
      | 003  |
      | 004  |
      | 005  |

  Scenario: Success from App Navigation
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Organizations "001,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "app-navigation-access-control"
    And the User clicks on the Element with Cypress ID "app-navigation-access-control-organizations"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/access-control/organizations"
    And the Element with Cypress ID "organizations-table" should be visible
    And the Element with Cypress ID "row-0 name" should have the text as "Acme Inc. SP"
    And the Element with Cypress ID "row-0 created_date" should have the text as "15 Apr 2024"
    And the Element with Cypress ID "badge-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d" should have the text as "Active"
    And the IAM Service Providers request has been intercepted to return the Organizations "003,001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "sort-icon-name"
    And the Element with Cypress ID "sort-icon-name" should NOT have a class "mm-table-header-cell--icon-focused"
    And the intercepted requests have resolved
    And the Element with Cypress ID "row-0 name" should have the text as "Org 001"

  Scenario: Org Details from Overview
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/access-control/organizations"
    And the intercepted requests have resolved
    And the Element with Cypress ID "organizations-table" should be visible
    And the Element with Cypress ID "row-0 name" should have the text as "Acme Inc. SP"
    And the IAM Service Providers request has been intercepted to return the Organization with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Billing and Invoicing request has been intercepted to return the billing address "001" from Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    When the User clicks on the Element with Cypress ID "table-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/access-control/organizations/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the Element with Cypress ID "org-name mm-data-iterator-item-text" should have the text as "Acme Inc. SP"
    And the billing request has been intercepted to return the charges for Service Consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    When the User clicks on the Element with Cypress ID "payments-expandable"
    Then the Element with Cypress ID "payment-id-column-3fa85f64-5717-4562-b3fc-2c963f66afa6" should have the text as "3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Licenses request has been intercepted to return for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" the Active Licenses "001" for service consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    Then the User clicks on the Element with Cypress ID "licenses-expandable"
    Then the Element with Cypress ID "licenses-table row-0 agreement_name" should have the text as "ABC Group"
    And the Policies request has been intercepted to return the Organization with Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for filter "001" and with org id "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    Then the User clicks on the Element with Cypress ID "policies-expandable"
    And the Contracting request has been intercepted to return the legal documents "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    Then the User clicks on the Element with Cypress ID "legal-docs-expandable"
    And the IAM Service Providers request has been intercepted to return the Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" and Organization "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    Then the User clicks on the Element with Cypress ID "users-expandable"
    And the Billing and Invoicing request has been intercepted to return the Invoices "001" for Service Consumer "0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    Then the User clicks on the Element with Cypress ID "invoices-expandable"
    Then the Element with Cypress ID "invoices-table row-0 id" should have the text as "Invoice001"
    Then the Element with Cypress ID "legal-documents-table row-0 name" should have the text as "doc name"
    Then the Element with Cypress ID "customers-policies-table row-0 name" should have the text as "Policy 1"
    Then the Element with Cypress ID "users-details-table row-0 name" should have the text as "test test"

  Scenario: Successfully created organization
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to create customer "Org 001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/access-control/organizations"
    And the intercepted requests have resolved
    And the Element with Cypress ID "button-create-organization" should exist
    And the User clicks on the Element with Cypress ID "button-create-organization"
    And the Element with Cypress ID "dialog-create-customer" should be visible
    And the User enters text "Org 001" in Input inside Element with Cypress ID "input-create-customer-organization"
    And the User enters text "example@example.com" in Input inside Element with Cypress ID "input-create-customer-admin-email"
    And the User enters text "user@example.com" in Input inside Element with Cypress ID "input-create-cutomer-user-emails"
    When the User clicks on the Element with Cypress ID "button-submit"
    Then the Element with Cypress ID "organizations-table" should be visible
    And the Element with Cypress ID "row-1 name" should have the text as "Org 001"

  Scenario: Create Organization Button should be visible when feature flag is enabled
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the feature flag "create_customer" is enabled
    When the User navigates to "/sp/access-control/organizations"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "button-create-organization" should exist

  Scenario: Create Organization Button should NOT be visible when feature flag is disabled
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the feature flag "create_customer" is disabled
    When the User navigates to "/sp/access-control/organizations"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "button-create-organization" should NOT exist

  Scenario: Import Organizations Button should be visible when feature flag is enabled
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the feature flag "import_customers" is enabled
    When the User navigates to "/sp/access-control/organizations"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "button-import-organizations" should exist

  Scenario: Import Organizations Button should NOT be visible when feature flag is disabled
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the feature flag "import_customers" is disabled
    When the User navigates to "/sp/access-control/organizations"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "button-import-organizations" should NOT exist
