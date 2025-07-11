Feature: Overview - Service Provider Dashboard

  Background: Service Provider Metrics
    And the IAM Service Provider Metrics request has been intercepted to return the Metrics for Service Provider "001"

  Scenario: Unauthorized

    Given no User is Signed In
    And the IAM OAuth Authorize redirects to the Login page
    When the User navigates to "/sp/dashboard"
    Then the User should be redirected to "/login"

  Scenario: Forbidden with non-Org User

    Given the User "001OnboardingCompleted" is Signed In
    When the User navigates to "/sp/dashboard"
    Then the Element with selector "#sp-metrics" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Forbidden with Org User which is not SP

    Given the User "002" is Signed In
    When the User navigates to "/sp/dashboard"
    Then the Element with selector "#sp-metrics" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  @ignore
  Scenario: Success with SP Admin from App Navigation

    Given the User "003" is Signed In
    And the User navigates to "/"
    And the User clicks on the Element with selector "#app-navigation-overview-sp"
    Then the User should be redirected to "/sp/dashboard"
    And the Element with selector "#sp-metrics" should be visible
    And the Element with selector "#sp-total-organizations" should have the text as "4"
    And the Element with selector "#sp-total-users" should have the text as "10"
    And the Element with selector "#sp-average-users-per-org" should have the text as "3"
    And the Element with selector "#active-users-chart" should be visible
    And the Element with selector "#signups-chart" should be visible
    And the Element with selector "#failed-logins-chart" should be visible

  Scenario: Success with SP Admin from direct URL

    Given the User "003" is Signed In
    When the User navigates to "/sp/dashboard"
    Then the Element with selector "#sp-metrics" should be visible
    And the Element with selector "#sp-total-organizations" should have the text as "4"
    And the Element with selector "#sp-total-users" should have the text as "10"
    And the Element with selector "#sp-average-users-per-org" should have the text as "3"
    And the Element with selector "#active-users-chart" should be visible
    And the Element with selector "#signups-chart" should be visible
    And the Element with selector "#failed-logins-chart" should be visible

  Scenario: Success with SP Editor from direct URL

    Given the User "004" is Signed In
    When the User navigates to "/sp/dashboard"
    Then the Element with selector "#sp-metrics" should be visible
    And the Element with selector "#sp-total-organizations" should have the text as "4"
    And the Element with selector "#sp-total-users" should have the text as "10"
    And the Element with selector "#sp-average-users-per-org" should have the text as "3"
    And the Element with selector "#active-users-chart" should be visible
    And the Element with selector "#signups-chart" should be visible
    And the Element with selector "#failed-logins-chart" should be visible

  Scenario: Success with SP Viewer from direct URL

    Given the User "005" is Signed In
    When the User navigates to "/sp/dashboard"
    Then the Element with selector "#sp-metrics" should be visible
    And the Element with selector "#sp-total-organizations" should have the text as "4"
    And the Element with selector "#sp-total-users" should have the text as "10"
    And the Element with selector "#sp-average-users-per-org" should have the text as "3"
    And the Element with selector "#active-users-chart" should be visible
    And the Element with selector "#signups-chart" should be visible
    And the Element with selector "#failed-logins-chart" should be visible
