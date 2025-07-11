Feature: Home

  Scenario: User is not Authenticated
    Given the IAM OAuth Authorize redirects to the Login page
    When the User navigates to "/"
    Then the User should be redirected to "/login"

  Scenario: Access Denied Logout
    Given the User "009-no-unit" is Signed In
    And the User navigates to "/"
    And the User should be redirected to "/access-denied"
    And the Element with Cypress ID "access-denied-logout-button" should be visible
    And the IAM Logout redirects to "/"
    When the User clicks on the Element with Cypress ID "access-denied-logout-button"
    And the intercepted requests have resolved
    Then the User should be redirected to "/"

  Scenario: Access Denied content and back to customer portal
    Given the User "009-no-unit" is Signed In
    And the User navigates to "/"
    And the User should be redirected to "/access-denied"
    And the Element with Cypress ID "access-denied-logout-button" should be visible
    And the Element with Cypress ID "page-not-found-title" should have the text as "Oops! You don't have access"
    And the Element with Cypress ID "message" should have the text as "You need permission to access the Admin Portal, please chat to your administrator to give you access"
    And the Element with Cypress ID "back-to-button" should have the text as " Back to Customer Portal"
    And the User navigates to "/"
    When the User clicks on the Element with Cypress ID "back-to-button"
    And the intercepted requests have resolved
    Then the User should be redirected to "/"

  Scenario: Should redirect to /getting-started if user is a SP Admin and not completed Getting Started
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User updated Onboarding Welcome Components with Fixture Id "002-first-step-completed" for "sp" app
    When the User navigates to "/"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/getting-started"

  Scenario: Should redirect to /applications if user is a SP Admin and completed Getting Started
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User updated Onboarding Welcome Components with Fixture Id "005-last-step-completed" for "sp" app
    When the User navigates to "/"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/applications"
