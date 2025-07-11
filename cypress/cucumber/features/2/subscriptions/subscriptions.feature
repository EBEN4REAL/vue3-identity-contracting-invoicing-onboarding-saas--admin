Feature: Subscriptions - Subscriptions

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/subscriptions"
    Then the Element with Cypress ID "subscriptions-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/subscriptions"
    Then the Element with Cypress ID "subscriptions-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Success with SP Admin from App Navigation
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the Licenses "001,002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Events request has been intercepted to return the Agreement Metrics "001" for Service Provider "001"
    And the User clicks on the Element with selector "#app-navigation-subscriptions"
    And the User clicks on the Element with selector "#app-navigation-subscriptions-subscriptions"
    And the intercepted requests have resolved
    And the Element with Cypress ID "subscriptions-table" should be visible
    And the Licenses request has been intercepted to return the License "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "name-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Element with Cypress ID "back-to-link" should have the text as " Back to Subscriptions"
    When the User clicks on the Element with Cypress ID "back-to-link"
    Then the User should be redirected to "sp/subscriptions"

  Scenario: Should be possible to go to New subscription page
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the Licenses "001,002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Events request has been intercepted to return the Agreement Metrics "001" for Service Provider "001"
    And the User clicks on the Element with selector "#app-navigation-subscriptions"
    And the User clicks on the Element with selector "#app-navigation-subscriptions-subscriptions"
    And the intercepted requests have resolved
    And the Element with Cypress ID "subscriptions-table" should be visible
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001" for Service Provider "001" with query params "*"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-open-subscriptions"
    And the intercepted requests have resolved
    And the User should be redirected to "sp/new-subscription/allocate"
    And the Element with Cypress ID "header-title" should have the text as "New Subscription"
    And the Element with Cypress ID "customer-search" should exist
    And the Element with Cypress ID "confirm-button" should exist
    And the Element with Cypress ID "cancel-button" should exist
    When the User clicks on the Element with Cypress ID "cancel-button"
    Then the User should be redirected to "sp/subscriptions"

  Scenario: Should allocate plan correctly
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the Licenses "001,002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Events request has been intercepted to return the Agreement Metrics "001" for Service Provider "001"
    And the User clicks on the Element with selector "#app-navigation-subscriptions"
    And the User clicks on the Element with selector "#app-navigation-subscriptions-subscriptions"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001" for Service Provider "001" with query params "*"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "button-open-subscriptions"
    And the intercepted requests have resolved
    And the User force clicks on the Element with Cypress ID "customer-search autocomplete"
    And the User force clicks on the Element with Cypress ID "customer-search mm-autocomplete-option-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d"
    And the User clicks on the Element with Cypress ID "select-license autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to assign an agreement with id "3fa85f64-5717-4562-b3fc-2c963f66afa7" to an organization with id "001"
    When the User clicks on the Element with Cypress ID "confirm-button"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/subscriptions"
    And the Element with Cypress ID "row-0 service_consumer_name" should have the text as "Org 001"

  Scenario: Agreement Metrics section should have proper data
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Events request has been intercepted to return the Agreement Metrics "001" for Service Provider "001"
    And the Licenses request has been intercepted to return the Licenses "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/subscriptions"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "total-active-licenses-card" should exist
    And the Element with Cypress ID "total-active-licenses-card-value" should have the text as "11"
    And the Element with Cypress ID "total-new-subscriptions-card-value" should have the text as "2"
    And the Element with Cypress ID "total-cancelled-subscriptions-card-value" should have the text as "2"
