Feature: SC to SP Journey

  Scenario: Should be possible to replicate sc to sp journey
    Given the User "SCOrg" is Signed In
    When the User navigates to "/login-sc-to-sp"
    Then the Element with Cypress ID "org-message" should exist
    And the Element with Cypress ID "back-customer-portal" should exist
    And the Element with Cypress ID "continue" should exist
    And the IAM Organization request has been intercepted to register as a SP the Organization "8b2e7a85-a1d9-4f6c-b7e2-8d3f9c24e591"
    And the User "SCOrg" is Signed In
    And the IAM User @me request has been intercepted to return the User "SCOrg"
    Then the User clicks on the Element with Cypress ID "continue"
    Then the User navigates to "/sp/getting-started"

  Scenario: Should be possible to go back to customer portal
    Given the User "SCOrg" is Signed In
    When the User navigates to "/login-sc-to-sp"
    And the User clicks on the Element with Cypress ID "back-customer-portal"
    Then the User should be redirected to "/"
