Feature: Onboarding - User Welcome Component

  Scenario: Should redirect user to Getting Started page, Highlight Getting Started link as active if All Steps have not been completed, render correct page info and disable navigation Items

    Given the User "003" is Signed In
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "002-first-step-completed" for "sp" app
    When the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-getting-started-progress-bar-container" should be visible
    And the Element with Cypress ID "getting-started-title" contains the text as "Welcome User"
    And the Element with Cypress ID "getting-started-subtitle" contains the text as "Get set up in just a few minutes with the steps below"
    And the Element with Cypress ID "mm-navigation-item-getting-started" should have a class "mm-app-navigation-item--link--active"

  Scenario: Should show correct progress bar percentage when user has completed no steps

    Given the User "003" is Signed In
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "001-no-step-completed" for "sp" app
    When the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-getting-started-progress-bar-label" should have the text as "0% Completed"

  Scenario: Should show correct progress bar percentage and redirect to correct pages on click of the CTAs for users with first step completed

    Given the User "003" is Signed In
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "002-first-step-completed" for "sp" app
    When the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-getting-started-progress-bar-label" should have the text as "20% Completed"
    And the User clicks on the Element with Cypress ID "getting-started-step-button-configure-access"
    And the User should be redirected to "/sp/access-control/policy-based#Policies"

 Scenario: Should be able to update progress bar percentage when Step is Marked as Completed, collapse current step and activate next step

    Given the User "003" is Signed In
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "002-first-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the Element with Cypress ID "mm-getting-started-progress-bar-label" should have the text as "20% Completed"
    And the Onboarding Welcome Components POST request has been intercepted to update progress for Onboarding Step and User Welcome Component with FixtureId "002-welcome-component" for "sp" app
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User updated Onboarding Welcome Components with Fixture Id "003-second-step-completed" for "sp" app
    When the User clicks on the Element with Cypress ID "mm-getting-started-step-ConfigureAccessRequirements-checkbox"
    And the Onboarding User Welcome Components POST request has been completed
    And the updated Onboarding Welcome Components GET request has been completed
    Then the Element with Cypress ID "mm-getting-started-progress-bar-label" should have the text as "40% Completed"
    And the Onboarding Welcome Components DELETE request has been intercepted to update progress for Onboarding Step and User Welcome Component with FixtureId "002-welcome-component" for "sp" app
    And the User clicks on the Element with Cypress ID "mm-getting-started-step-ConfigureAccessRequirements"
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User updated Onboarding Welcome Components with Fixture Id "002-first-step-completed" for "sp" app
    And the User clicks on the Element with Cypress ID "mm-getting-started-step-ConfigureAccessRequirements-checkbox"
    And the Onboarding User Welcome Components DELETE request has been completed
    And the updated Onboarding Welcome Components GET request has been completed
    And the Element with Cypress ID "mm-getting-started-progress-bar-label" should have the text as "20% Completed"

  Scenario: Redirect User to Dashboard, Remove Getting Started Link From Navigation and Enable Navigation Items when user completes all Getting Started Steps

    Given the User "003" is Signed In
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User Onboarding Welcome Components with Fixture Id "004-fourth-step-completed" for "sp" app
    And the User navigates to "/sp/getting-started"
    And the intercepted requests have resolved
    And the Element with Cypress ID "mm-getting-started-progress-bar-label" should have the text as "80% Completed"
    And the Onboarding Welcome Components POST request has been intercepted to update progress for Onboarding Step and User Welcome Component with FixtureId "005-welcome-component" for "sp" app
    And the Onboarding Welcome Components GET request has been intercepted to retrieve User updated Onboarding Welcome Components with Fixture Id "005-last-step-completed" for "sp" app
    When the User clicks on the Element with Cypress ID "mm-getting-started-step-SetupYourOrganization-checkbox"
    And the Onboarding User Welcome Components POST request has been completed
    And the updated Onboarding Welcome Components GET request has been completed
    Then the Element with Cypress ID "mm-navigation-item-getting-started" should NOT exist
    And the User should be redirected to "/sp/applications"
