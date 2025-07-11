Feature: Subscriptions - Plans

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/plans"
    Then the Element with Cypress ID "subscriptions-plans-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/plans"
    Then the Element with Cypress ID "subscriptions-plans-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario Outline: Success with from direct URL
    Given the User "<user>" is Signed In
    And the IAM User @me request has been intercepted to return the User "<user>"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002,003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "002" for Service Provider "001"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    When the User navigates to "/sp/plans"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "subscriptions-plans-table" should be visible
    And the Element with Cypress ID "subscriptions-plans-table row-0 name" contains the text as "Agreement Type 002"

    Examples: Users
      | user |
      | 003  |
      | 004  |
      | 005  |

  Scenario: Success with SP Admin from App Navigation
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002,003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "002" for Service Provider "001"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    When the User clicks on the Element with selector "#app-navigation-subscriptions"
    And the User clicks on the Element with selector "#app-navigation-subscriptions-plans"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "subscriptions-plans-table" should be visible
    And the Element with Cypress ID "subscriptions-plans-table row-0 name" contains the text as "Agreement Type 002"
    And the Element with Cypress ID "subscriptions-plans-table row-0 description" contains the text as "Agreement Type 002 Description"
    And the Element with Cypress ID "sort-icon-name" should have a class "mm-table-header-cell--icon-focused"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003,002" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:desc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "002" for Service Provider "001"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "sort-icon-name"
    And the intercepted requests have resolved
    And the Element with Cypress ID "subscriptions-plans-table row-0 name" contains the text as "Agreement Type 003"
    And the Element with Cypress ID "sort-icon-name" should NOT have a class "mm-table-header-cell--icon-focused"

  Scenario: Should redirect to License details page when clicking on View from Actions
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002,003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "002" for Service Provider "001"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User navigates to "/sp/plans"
    And the intercepted requests have resolved
    And the Element with Cypress ID "subscriptions-plans-table" should be visible
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return no results for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    When the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-view"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Element with Cypress ID "internal-name mm-data-iterator-item-text" should have the text as "Agreement Type 003"

  Scenario: Should redirect to License details page when clicking on License Name
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User navigates to "/sp/plans"
    And the intercepted requests have resolved
    And the Element with Cypress ID "subscriptions-plans-table" should be visible
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return no results for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "column-name-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Element with Cypress ID "internal-name mm-data-iterator-item-text" should have the text as "Agreement Type 003"
    And the Element with Cypress ID "external-name mm-data-iterator-item-text" should have the text as "Agreement Type 003 External"

  Scenario: Should redirect to License edit page when clicking on Edit from Actions
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User navigates to "/sp/plans"
    And the intercepted requests have resolved
    And the Element with Cypress ID "subscriptions-plans-table" should be visible
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return no results for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-edit"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7?editMode=true"

  Scenario: Should redirect to Create license page when Create Plan button is clicked
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User navigates to "/sp/plans"
    And the intercepted requests have resolved
    And the Element with Cypress ID "subscriptions-plans-table" should be visible
    And the Configuration GET Legal Document Types request has been intercepted to return no results for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "button-open-licenses"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/new"

  Scenario: Should be possible to Duplicate plan from overview
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User navigates to "/sp/plans"
    And the intercepted requests have resolved
    And the Element with Cypress ID "subscriptions-plans-table" should be visible
    And the Configuration GET Legal Document Types request has been intercepted to return no results for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-duplicate"
    And the intercepted requests have resolved
    Then the User should be redirected to "sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/new?duplicateMode=true"
    And the Input with Cypress ID "input-license-name" should have value as "Agreement Type 003"
    And the Input with Cypress ID "input-license-external-name" should have value as "Agreement Type 003 External"
    And the Textarea inside Element with Cypress ID "input-license-description" should have the value as "Agreement Type 003 Description"
