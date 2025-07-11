Feature: Service Provider - Subscription Details

  Scenario: Should be possible to go to subscription details page with correct info
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the feature flag "billing_and_invoicing" is enabled
    And the Events request has been intercepted to return the Agreement Metrics "001" for Service Provider "001"
    And the Licenses request has been intercepted to return the Licenses "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with selector "#app-navigation-subscriptions"
    And the User clicks on the Element with selector "#app-navigation-subscriptions-subscriptions"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the License "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the billing request has been intercepted to return the agreement with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "name-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    Then the User should be redirected to "sp/subscription/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Element with Cypress ID "header-title" contains the text as "License 3 for Acme Inc. SP"
    And the Element with Cypress ID "organization-name" contains the text as "Acme Inc. SP"
    And the Element with Cypress ID "effective-from" contains the text as "28 Mar 2024"
    And the Element with Cypress ID "effective-to" should NOT exist
    And the Element with Cypress ID "pricing-model" contains the text as "Free"
    And the Element with Cypress ID "price" should NOT exist
    And the Element with Cypress ID "billing-period" should NOT exist
    And the Element with Cypress ID "next-billing-date" should NOT exist

  Scenario: Plan details view successfully shows data when we have a price and recurring billing
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the Events request has been intercepted to return the Agreement Metrics "001" for Service Provider "001"
    And the Licenses request has been intercepted to return the Licenses "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with selector "#app-navigation-subscriptions"
    And the User clicks on the Element with selector "#app-navigation-subscriptions-subscriptions"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the License "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the billing request has been intercepted to return the agreement with id "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "name-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    Then the User should be redirected to "sp/subscription/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Element with Cypress ID "header-title" contains the text as "License 3 for Acme Inc. SP"
    And the Element with Cypress ID "organization-name" contains the text as "Acme Inc. SP"
    And the Element with Cypress ID "effective-from" contains the text as "28 Mar 2024"
    And the Element with Cypress ID "pricing-model" contains the text as "Flat-fee recurring"
    And the Element with Cypress ID "price" contains the text as "0.5"
    And the Element with Cypress ID "billing-period" contains the text as "Daily"
    And the Element with Cypress ID "next-billing-date" contains the text as "-"

  Scenario: Payments Invoice and Legal docs tables should be populated
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the Events request has been intercepted to return the Agreement Metrics "001" for Service Provider "001"
    And the Licenses request has been intercepted to return the Licenses "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with selector "#app-navigation-subscriptions"
    And the User clicks on the Element with selector "#app-navigation-subscriptions-subscriptions"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the License "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the billing request has been intercepted to return the agreement with id "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "name-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    And the User should be redirected to "sp/subscription/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the billing request has been intercepted to return the charges for the Agreement "001" of Service Provider "001"
    And the User clicks on the Element with Cypress ID "payments-expandable"
    And the Element with Cypress ID "row-0 payment_method" contains the text as "STRIPE"
    And the User clicks on the Element with Cypress ID "invoices-expandable"
    And the Element with Cypress ID "row-0 date" contains the text as "5 Aug 2024"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "001" for for Service Provider "001"
    And the Configuration GET Legal Document Type PDF request has been intercepted to return the Legal Document Type "001" PDF URL for Service Provider "001"
    When the User clicks on the Element with Cypress ID "legal-docs-expandable"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "row-0 name" should have the text as "doc name"
