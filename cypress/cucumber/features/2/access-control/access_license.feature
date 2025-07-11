Feature: Access Control - Access License

  Scenario: Success with correct info displayed in Licenses tab
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002,003" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "002" for Service Provider "001"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User navigates to "/sp/access-control/access-license"
    And the intercepted requests have resolved
    And the Element with Cypress ID "tab-item-licenses" should have a class "mm-tabs-item--active"
    And the Element with Cypress ID "page-subtitle" contains the text as "Access license products configured"
    And the Element with Cypress ID "access-control-licenses-table row-0 name" contains the text as "Agreement Type 002"
    And the Element with Cypress ID "access-control-licenses-table row-0 description" contains the text as "Agreement Type 002 Description"
    And the Element with Cypress ID "sort-icon-name" should have a class "mm-table-header-cell--icon-focused"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003,002" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:desc"
    When the User clicks on the Element with Cypress ID "sort-icon-name"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "access-control-licenses-table row-0 name" contains the text as "Agreement Type 003"
    And the Element with Cypress ID "sort-icon-name" should NOT have a class "mm-table-header-cell--icon-focused"

  Scenario: Success with correct info displayed in Allocated Licenses tab
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002,003" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "002" for Service Provider "001"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User navigates to "/sp/access-control/access-license"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the Licenses "003,006" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" with query params "category=ACCESS&limit=10&offset=0&sort=effective_from_date:desc"
    And the User clicks on the Element with Cypress ID "tab-item-allocated-licenses"
    And the intercepted requests have resolved
    And the Element with Cypress ID "row-0 service_consumer_name" should have the text as "Org 003"
    And the Element with Cypress ID "row-0 agreement_name" should have the text as "License 3"
    And the Element with Cypress ID "row-0 effective_from_date" should have the text as "28 Mar 2024"
    And the Element with Cypress ID "row-0 valid_until" should have the text as "-"
    And the Element with Cypress ID "row-0 cancelled" should have the text as "Active"
    And the Element with Cypress ID "sort-icon-effective_from_date" should NOT have a class "mm-table-header-cell--icon-focused"
    And the Element with Cypress ID "sort-icon-agreement_name" should have a class "mm-table-header-cell--icon-focused"
    When the User clicks on the Element with Cypress ID "sort-icon-agreement_name"
    And the Licenses request has been intercepted to return the Licenses "006,003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" with query params "category=ACCESS&limit=10&offset=0&sort=name:asc"
    When the User clicks on the Element with Cypress ID "sort-icon-agreement_name"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "row-0 agreement_name" should have the text as "License 12"

  Scenario: Success with correct info displayed in Allocated Licenses tab with different license status scenarios
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002,003" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the User navigates to "/sp/access-control/access-license"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the Licenses "006,007,008" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "tab-item-allocated-licenses"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "access-control-allocated-licenses-table" should be visible
    And the Element with Cypress ID "row-0 agreement_name" should have the text as "License 12"
    And the Element with Cypress ID "row-0 cancelled" should have the text as "Active"
    And the Element with Cypress ID "row-1 agreement_name" should have the text as "License 12"
    And the Element with Cypress ID "row-1 cancelled" should have the text as "Pending"
    And the Element with Cypress ID "row-2 agreement_name" should have the text as "License 8"
    And the Element with Cypress ID "row-2 cancelled" should have the text as "Cancelled"

  Scenario: Should be possible to go to license details page clicking on actions button and payments and invoices sections should not appear
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002,003" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "002" for Service Provider "001"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User navigates to "/sp/access-control/access-license"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the Licenses "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "tab-item-allocated-licenses"
    And the intercepted requests have resolved
    And the billing request has been intercepted to return the agreement with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Licenses request has been intercepted to return the License "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-4a6f01d0-f3c6-4923-ad98-112d6d97355b-item-view-license"
    And the intercepted requests have resolved
    And the User should be redirected to "/sp/access-control/access-license/3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the Element with Cypress ID "payments-expandable" should NOT exist
    And the Element with Cypress ID "invoices-expandable" should NOT exist
    When the User clicks on the Element with Cypress ID "back-link"
    Then the User should be redirected to "/sp/access-control/access-license"

  Scenario: Should be possible to go to license details page clicking on License Name
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002,003" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "002" for Service Provider "001"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User navigates to "/sp/access-control/access-license"
    And the intercepted requests have resolved
    And the Licenses request has been intercepted to return the Licenses "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User clicks on the Element with Cypress ID "tab-item-allocated-licenses"
    And the intercepted requests have resolved
    And the billing request has been intercepted to return the agreement with id "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the Licenses request has been intercepted to return the License "003" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "actions-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "name-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/access-control/access-license/3fa85f64-5717-4562-b3fc-2c963f66afa7"

  Scenario: Should be possible to Duplicate license from overview
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "002,003" for Service Provider "001" with query params "category=ACCESS&limit=10&offset=0&sort=agreement_type.name:asc"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "002" for Service Provider "001"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User navigates to "/sp/access-control/access-license"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "row-0 actions"
    And the User clicks on the Element with Cypress ID "actions-dropdown-10431e7d-c789-4ebc-8988-b14406645d5c-item-duplicate"
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/licenses/new"
    And the Input with Cypress ID "input-license-name" should have value as "Agreement Type 002"
    And the Input with Cypress ID "input-license-external-name" should have value as "Agreement Type 002 External"
    And the Textarea inside Element with Cypress ID "input-license-description" should have the value as "Agreement Type 002 Description"
    And the Textarea inside Element with Cypress ID "input-license-external-description" should have the value as "Agreement Type 002 Description External"