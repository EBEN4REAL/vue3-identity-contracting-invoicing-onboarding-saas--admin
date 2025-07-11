Feature: Service Provider - Customers

  Scenario: Forbidden with non-Org User

    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/customers"
    Then the Element with Cypress ID "customers-table" should NOT exist
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP

    Given the User "002" is Signed In
    When the User navigates to "/sp/customers"
    Then the Element with Cypress ID "customers-table" should NOT exist
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Success with SP Admin from direct URL

    Given the User "003" is Signed In
    When the User navigates to "/sp/customers"
    Then the Element with Cypress ID "customers-table" should be visible

  Scenario: Success with SP Editor from direct URL

    Given the User "004" is Signed In
    When the User navigates to "/sp/customers"
    Then the Element with Cypress ID "customers-table" should be visible

  Scenario: Success with SP Viewer from direct URL

    Given the User "005" is Signed In
    When the User navigates to "/sp/customers"
    Then the Element with Cypress ID "customers-table" should be visible

  Scenario: Success with SP Admin from App Navigation

    Given the User "003" is Signed In
    And the User navigates to "/"
    When the User clicks on the Element with selector "#app-navigation-subscriptions"
    When the User clicks on the Element with selector "#app-navigation-subscriptions-customers"
    Then the User should be redirected to "/sp/customers"
    Then the Element with Cypress ID "customers-table" should be visible

  Scenario: Success with correct info displayed

    Given the User "003" is Signed In
    And the IAM Service Providers request has been intercepted to return the Organizations "001,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/customers"
    Then the Element with Cypress ID "customers-table" should be visible
    Then the Element with Cypress ID "row-0 name" should have the text as "Acme Inc. SP"
    Then the Element with Cypress ID "row-0 created_date" should have the text as "15 Apr 2024"
    Then the Element with Cypress ID "badge-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d" should have the text as "Active"
    And the IAM Service Providers request has been intercepted to return the Organizations "003,001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "sort-icon-name"
    Then the Element with Cypress ID "sort-icon-name" should NOT have a class "mm-table-header-cell--icon-focused"
    And the Element with Cypress ID "row-0 name" should have the text as "Org 001"

  Scenario: Successfully redirect to detailed view

    Given the User "003" is Signed In
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/customers"
    Then the Element with Cypress ID "customers-table" should be visible
    Then the Element with Cypress ID "row-0 name" should have the text as "Acme Inc. SP"
    When the User clicks on the Element with Cypress ID "table-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    Then the User should be redirected to "/sp/customers/0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"

  Scenario: Successfully created customer

    Given the User "003" is Signed In
    And the IAM Service Providers request has been intercepted to return the Organizations "001,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to create customer "Org 001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User navigates to "/sp/customers"
    And the Element with Cypress ID "button-create-customer" should exist
    And the User clicks on the Element with Cypress ID "button-create-customer"
    And the Element with Cypress ID "dialog-create-customer" should be visible
    And the User enters text "Org 001" in Input inside Element with Cypress ID "input-create-customer-organization"
    And the User enters text "example@example.com" in Input inside Element with Cypress ID "input-create-customer-admin-email"
    And the User enters text "user@example.com" in Input inside Element with Cypress ID "input-create-cutomer-user-emails"
    When the User clicks on the Element with Cypress ID "button-submit"
    Then the Element with Cypress ID "customers-table" should be visible
    And the Element with Cypress ID "row-1 name" should have the text as "Org 001"

  Scenario: Create Customer Button should be visible when feature flag is enabled

    Given the User "003" is Signed In
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the feature flag "create_customer" is enabled
    When the User navigates to "/sp/customers"
    Then the Element with Cypress ID "button-create-customer" should exist

  Scenario: Create Customer Button should NOT be visible when feature flag is disabled

    Given the User "003" is Signed In
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the feature flag "create_customer" is disabled
    When the User navigates to "/sp/customers"
    Then the Element with Cypress ID "button-create-customer" should NOT exist

  Scenario: Import Customers Button should be visible when feature flag is enabled

    Given the User "003" is Signed In
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the feature flag "import_customers" is enabled
    When the User navigates to "/sp/customers"
    Then the Element with Cypress ID "button-import-customers" should exist

  Scenario: Import Customers Button should NOT be visible when feature flag is disabled

    Given the User "003" is Signed In
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the feature flag "import_customers" is disabled
    When the User navigates to "/sp/customers"
    Then the Element with Cypress ID "button-import-customers" should NOT exist
    