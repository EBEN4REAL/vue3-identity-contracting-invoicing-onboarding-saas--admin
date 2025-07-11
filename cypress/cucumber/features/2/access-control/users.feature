Feature: Access Control - Users

  Scenario: Forbidden with non-Org User
    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/access-control/users"
    Then the Element with Cypress ID "access-control-users-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP
    Given the User "002" is Signed In
    When the User navigates to "/sp/access-control/users"
    Then the Element with Cypress ID "access-control-users-table" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario Outline: Success from direct URL
    Given the User "<user>" is Signed In
    And the IAM User @me request has been intercepted to return the User "<user>"
    And the IAM Service Providers request has been intercepted to return the Organization Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User navigates to "/sp/access-control/users"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "access-control-users-table" should be visible
    And the Element with Cypress ID "access-control-users-table row-0 name" should have the text as "test test"

    Examples: Users
      | user |
      | 003  |
      | 004  |
      | 005  |

  Scenario: Success from App Navigation
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Organization Users "001" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "app-navigation-access-control"
    And the User clicks on the Element with Cypress ID "app-navigation-access-control-users"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/access-control/users"
    And the Element with Cypress ID "access-control-users-table" should be visible
    And the Element with Cypress ID "access-control-users-table row-0 name" should have the text as "test test"

  Scenario: Should be possible to go to details view by clicking on User Name and actions button
    Given the User "003" is Signed In
    And the IAM User @me request has been intercepted to return the User "003"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Organization Users "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User clicks on the Element with Cypress ID "app-navigation-access-control"
    And the User clicks on the Element with Cypress ID "app-navigation-access-control-users"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/access-control/users"
    And the IAM Service Providers request has been intercepted to return the Organization User "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    When the User force clicks on the Element with Cypress ID "column-21697fd7-8f71-4e32-9834-d5cfbf3d5d3d"
    Then the User should be redirected to "/sp/access-control/users/00000000-0000-0000-0002-000000000001/user_details/21697fd7-8f71-4e32-9834-d5cfbf3d5d3d"
    And the User clicks on the Element with Cypress ID "back-to-link"
    And the IAM Service Providers request has been intercepted to return the Organization Users "002" for Service Provider "4a6f01d0-f3c6-4923-ad98-112d6d97355b"
    And the User force clicks on the Element with Cypress ID "actions"
    And the User force clicks on the Element with Cypress ID "actions-dropdown-21697fd7-8f71-4e32-9834-d5cfbf3d5d3d-item-view-user-details"
    Then the User should be redirected to "/sp/access-control/users/00000000-0000-0000-0002-000000000001/user_details/21697fd7-8f71-4e32-9834-d5cfbf3d5d3d"