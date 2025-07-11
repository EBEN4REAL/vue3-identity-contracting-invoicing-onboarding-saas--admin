Feature: Configuration - Plans

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/configuration"
    Then the Element with Cypress ID "plans-table" should NOT exist
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/configuration"
    Then the Element with Cypress ID "plans-table" should NOT exist
    Then the Element with selector "#title" should have the text as "404"

  Scenario: Success with SP Admin from direct URL
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the Element with Cypress ID "tab-item-plans" should exist after scrolling into view
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    When the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "plans-table" should exist

  Scenario: Page should have proper data and sort by name
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the Element with Cypress ID "tab-item-plans" should exist after scrolling into view
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002,003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    And the Element with Cypress ID "page-subtitle" contains the text as "Plans describe the conditions for customers to get access to your applications"
    And the Element with Cypress ID "plans-table row-0 name" contains the text as "Agreement Type 002"
    And the Element with Cypress ID "plans-table row-0 description" contains the text as "Agreement Type 002 Description"
    And the Element with Cypress ID "sort-icon-name" should have a class "mm-table-header-cell--icon-focused"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003,002" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:desc"
    When the User clicks on the Element with Cypress ID "sort-icon-name"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "plans-table row-0 name" contains the text as "Agreement Type 003"
    And the Element with Cypress ID "sort-icon-name" should NOT have a class "mm-table-header-cell--icon-focused"

  Scenario: Add Plan button should redirect User to Plan Create page
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the Element with Cypress ID "tab-item-plans" should exist after scrolling into view
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for Autocomplete
    And the contracting request has been intercepted to return the documents "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "button-create-plan"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/new"
    And the Element with Cypress ID "tab-item-pricing" should be visible
    And the Element with Cypress ID "button-add-feature" should be visible

  Scenario: Should redirect to Plan Details via dropdown in table cell actions
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the Element with Cypress ID "tab-item-plans" should exist after scrolling into view
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-view"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"

  Scenario: Should redirect to Plan Details via click on table cell name
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the Element with Cypress ID "tab-item-plans" should exist after scrolling into view
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Policies GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "column-name-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"

#   TODO: Duplicating is broken
#  Scenario: Should be possible to Duplicate Plan from overview
#    Given the User "004" is Signed In
#    And the User navigates to "/sp/configuration"
#    And the Element with Cypress ID "tab-item-plans" should exist after scrolling into view
#    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
#    And the User clicks on the Element with Cypress ID "tab-item-plans"
#    And the intercepted requests have resolved
#    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the License with id "003"
#    And the Policies request has been intercepted to return the Policies "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" for Autocomplete
#    And the contracting request has been intercepted to return the documents "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
#    And the contracting request has been intercepted to return the documents "001" for agreement "bbac1962-adaf-4393-a1d7-13962c9fb3fd" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
#    And the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
#    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-duplicate"
#    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7?duplicateMode=true"
#    And the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/new"
#    And the User types "External Name" in Input inside Element with Cypress ID "input-license-external-name"
#    And the User types "NEW LicenseName" in Input inside Element with Cypress ID "input-license-name"
#    And the User types "NEW External Description" in Textarea inside Element with Cypress ID "input-license-external-description"
#    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to create the License with id "001-Updated"
#    And the User clicks on the Element with Cypress ID "button-save-license"
#    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to fetch the License with id "001-Updated"
#    And the Element with Cypress ID "internal-name mm-data-iterator-item-text" should have the text as "NEW LicenseName"
#    And the Element with Cypress ID "external-description mm-data-iterator-item-text" should have the text as "NEW External Description"

  Scenario: Should be possible to Delete Plan from overview
    Given the User "004" is Signed In
    And the IAM User @me request has been intercepted to return the User "004"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the Element with Cypress ID "tab-item-plans" should exist after scrolling into view
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002,003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-delete"
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to delete the License with id "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Element with Cypress ID "dialog-title" should have the text as "Delete Plan"
    When the User clicks on the Element with Cypress ID "confirm-delete-license button-confirm-delete-license"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "plans-table row-0 name" should have the text as "Agreement Type 002"

  Scenario: Should not be possible to Delete license if its already been used
    Given the User "004" is Signed In
    And the User navigates to "/sp/configuration"
    And the Element with Cypress ID "tab-item-plans" should exist after scrolling into view
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "004" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "004" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-plans"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "actions-dd04120e-3476-440e-a75a-19ddf12bfed5"
    Then the Element with Cypress ID "actions-dropdown-dd04120e-3476-440e-a75a-19ddf12bfed5-item-delete" should have a class "mm-dropdown-item--disabled"
    And the Element with Cypress ID "actions-dropdown-dd04120e-3476-440e-a75a-19ddf12bfed5-item-hint" should have the text as "You cannot delete this plan as there are active instances of it."
