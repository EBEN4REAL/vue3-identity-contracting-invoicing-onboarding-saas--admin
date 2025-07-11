Feature: Service Provider - Filters

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/configuration"
    Then the Element with Cypress ID "filters-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/configuration"
    Then the Element with Cypress ID "filters-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario Outline: Success with SP User from direct URL
    Given the User "<user>" is Signed In
    And the IAM User @me request has been intercepted to return the User "<user>"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    When the User clicks on the Element with Cypress ID "tab-item-filters"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "filters-table" should be visible

    Examples: Users
      | user |
      | 003  |
      | 004  |
      | 005  |

  Scenario: Success with SP Admin from App Navigation and redirect to detail view
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/"
    And the intercepted requests have resolved
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User clicks on the Element with selector "#app-navigation-configuration"
    And the User should be redirected to "/sp/configuration"
    And the intercepted requests have resolved
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the User clicks on the Element with Cypress ID "tab-item-filters"
    And the intercepted requests have resolved
    And the Element with Cypress ID "filters-table" should be visible
    And the Element with Cypress ID "sort-icon-name" should have a class "mm-table-header-cell--icon-focused"
    And the Element with Cypress ID "filters-table row-0 name" should have the text as "Office Hours"
    And the Element with Cypress ID "filters-table row-0 description" should have the text as "Filter for Office Hours"
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "003"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "004"
    And the Configuration GET Resource Type request has been intercepted to return the Resource Type "001" for Service Provider "001"
    And the Configuration GET Resource Attribute Type request has been intercepted to return the Resource Attribute Type "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "column-name-e418fd93-0d10-4c1e-b8e4-b29cddc456b0"
#    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/e418fd93-0d10-4c1e-b8e4-b29cddc456b0"

  Scenario: Should not be possible to delete a filter if there is active instances
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Filters request has been intercepted to return the Filters "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "tab-item-filters"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "actions-002"
    Then the Element with Cypress ID "actions-dropdown-002-item-delete" should have a class "mm-dropdown-item--disabled"
    And the Element with Cypress ID "actions-dropdown-002-item-hint" should have the text as "You cannot delete this filter as there are active instances of it."

  Scenario: Should be possible to duplicate a filter from the overview
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "tab-item-filters"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "007"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "008"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001-item-duplicate"
    And the intercepted requests have resolved
    And the User should be redirected to "sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/new"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to create the Filter with id "007"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "007"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    And the intercepted requests have resolved
    Then the User should be redirected to "sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/001"

  Scenario: Should be possible to go to edit a filter from the overview
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the Filters request has been intercepted to return the Filters "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "tab-item-filters"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "007"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filter with id "008"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the Filters with id "001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-001-item-edit"
    And the intercepted requests have resolved
    And the User should be redirected to "sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/filters/001"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to update the Filter with id "007"
    When the User clicks on the Element with Cypress ID "button-save-filter"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "button-save-filter" should NOT exist
