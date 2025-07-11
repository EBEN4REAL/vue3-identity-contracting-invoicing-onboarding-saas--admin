Feature: Service Provider - Cancel License

  Scenario: Cancel License Dialog with correct info

    Given the User "003" is Signed In
    And the Licenses request has been intercepted to return the Licenses "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/access-control/access-license#allocated_licenses"
    Then the Element with Cypress ID "access-control-allocated-licenses-table" should be visible
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6-item-cancel-license"
    Then the Element with Cypress ID "dialog-cancel-license" should be visible
    Then the Element with Cypress ID "dialog-title" should have the text as "Cancel License"
    Then the Element with Cypress ID "dialog-subtitle" should have the text as "Are you sure you want to cancel this license?"
    Then the Element with Cypress ID "button-cancel" should have the text as "No"
    Then the Element with Cypress ID "button-submit" should have the text as " Yes, Cancel "

   Scenario: Should be possible to close the Cancel License Dialog

    Given the User "003" is Signed In
    And the Licenses request has been intercepted to return the Licenses "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
     And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/access-control/access-license#allocated_licenses"
    Then the Element with Cypress ID "access-control-allocated-licenses-table" should be visible
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6-item-cancel-license"
    When the User clicks on the Element with Cypress ID "button-cancel"
    Then the Element with Cypress ID "dialog-cancel-license" should NOT exist

   Scenario: Cancel License

    Given the User "003" is Signed In
    And the Licenses request has been intercepted to return the Licenses "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
     And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/access-control/access-license#allocated_licenses"
    Then the Element with Cypress ID "access-control-allocated-licenses-table" should be visible
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa6-item-cancel-license"
    Then the Element with Cypress ID "dialog-cancel-license" should be visible
    And the Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b" request has been intercepted to cancel the License with id "3fa85f64-5717-4562-b3fc-2c963f66afa6"
    When the User clicks on the Element with Cypress ID "button-submit"
    Then the Element with Cypress ID "dialog-cancel-license" should NOT exist

  Scenario: Cancel license button should be disabled if license was already cancelled

    Given the User "003" is Signed In
    And the Licenses request has been intercepted to return the Licenses "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the IAM Service Providers request has been intercepted to return the Organizations "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/access-control/access-license#allocated_licenses"
    Then the Element with Cypress ID "access-control-allocated-licenses-table" should be visible
    When the User clicks on the Element with Cypress ID "actions-2fa85f64-5717-4562-b3fc-2c963f66afa6"
    Then the Element with Cypress ID "actions-dropdown-0edfc35c-e116-4c2e-8e35-8a28b68d5f6d-item-cancel-license" should have a class "mm-dropdown-item--disabled"
