Feature: Signup

  Scenario: Should redirect to SC App Signup
    Given the IAM OAuth Authorize redirects to the Signup page
    And the SC App Signup has been intercepted
    When the User navigates to "/signup"
    Then the User should be redirected to the SC App "/signup?next_url="
