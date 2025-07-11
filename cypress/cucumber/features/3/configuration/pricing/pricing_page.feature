Feature: Service Provider - Pricing Page

  Scenario: Forbidden with non-service provider
    Given the User "001OnboardingCompleted" is Signed In
    And the IAM User @me request has been intercepted to return the User "001OnboardingCompleted"
    When the User navigates to "/sp/configuration"
    Then the Element with Cypress ID "tab-item-pricing-page" should NOT exist
    And the Element with selector "#title" should have the text as "404"

  Scenario: Pricing should NOT be visible when feature flag is disabled
    Given the User "MMAdmin001" is Signed In
    And the feature flag "pricing" is disabled
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    When the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "tab-item-pricing-page" should NOT exist

  Scenario: Successful view page with disable checkbox and no plans added
    Given the User "MMAdmin001" is Signed In
    And the feature flag "pricing" is enabled
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding OauthClient Settings "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "no-results" for Service Provider "001" with query params "limit=10&offset=0&include_in_self_service=true&sort=agreement_type.self_service_order:asc&disable_pagination=true"
    When the User clicks on the Element with Cypress ID "tab-item-pricing-page"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "empty-licenses-section" should exist
    And the Element with Cypress ID "button-add-plan-card" should NOT exist

  Scenario: Successful go to edit mode and check checkbox
    Given the User "MMAdmin001" is Signed In
    And the feature flag "pricing" is enabled
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding OauthClient Settings "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "no-results" for Service Provider "001" with query params "limit=10&offset=0&include_in_self_service=true&sort=agreement_type.self_service_order:asc&disable_pagination=true"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-pricing-page"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-pricing-button"
    And the User clicks on the Element with Cypress ID "self-service-checkbox"
    And the Element with Cypress ID "button-add-plan-card" should exist
    When the User clicks on the Element with Cypress ID "save-pricing-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "mm-toast-text" should have the text as "To enable the pricing page you need to add at least one plan"

  Scenario: Successful discard changes
    Given the User "MMAdmin001" is Signed In
    And the feature flag "pricing" is enabled
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding OauthClient Settings "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "no-results" for Service Provider "001" with query params "limit=10&offset=0&include_in_self_service=true&sort=agreement_type.self_service_order:asc&disable_pagination=true"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-pricing-page"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-pricing-button"
    And the User clicks on the Element with Cypress ID "self-service-checkbox"
    And the User clicks on the Element with Cypress ID "discard-pricing-button"
    And the Element with Cypress ID "confirm-discard-dialog" should exist
    And the User clicks on the Element with Cypress ID "button-cancel-discard"
    And the Element with Cypress ID "confirm-discard-dialog" should NOT exist
    And the User clicks on the Element with Cypress ID "discard-pricing-button"
    When the User clicks on the Element with Cypress ID "button-confirm-discard"
    Then the Element with Cypress ID "confirm-discard-dialog" should NOT exist
    And the Element with Cypress ID "edit-pricing-button" should exist
    And the Element with Cypress ID "self-service-checkbox-input" should exist
    And the Element with Cypress ID "self-service-checkbox-input" should have a class "disabled"

  Scenario: Should be possible to add plan
    Given the User "MMAdmin001" is Signed In
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding OauthClient Settings "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "001" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "no-results" for Service Provider "001" with query params "limit=10&offset=0&include_in_self_service=true&sort=agreement_type.self_service_order:asc&disable_pagination=true"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "006" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-pricing-page"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-pricing-button"
    And the User clicks on the Element with Cypress ID "self-service-checkbox"
    And the User clicks on the Element with Cypress ID "button-add-plan-card"
    And the Element with Cypress ID "add-plan-dialog" should exist
    And the Element with Cypress ID "button-confirm-add-plan" should have the attribute "disabled" as "disabled"
    And the User clicks on the Element with Cypress ID "button-cancel-add-plan"
    And the Element with Cypress ID "add-plan-dialog" should NOT exist
    And the User clicks on the Element with Cypress ID "button-add-plan-card"
    And the User clicks on the Element with Cypress ID "add-plan-select autocomplete"
    And the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa6" should have the text as "Agreement Type 001 Agreement Type 001 Description"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa6"
    And the Element with Cypress ID "button-confirm-add-plan" should NOT have the attribute "disabled"
    And the User clicks on the Element with Cypress ID "button-confirm-add-plan"
    And the Element with Cypress ID "add-plan-dialog" should NOT exist
    And the Element with Cypress ID "button-add-plan" should exist
    And the Element with Cypress ID "plans-table" should exist
    And the Element with Cypress ID "name-3fa85f64-5717-4562-b3fc-2c963f66afa6" should have the text as "Agreement Type 001"
    When the User clicks on the Element with Cypress ID "button-add-plan"
    And the User clicks on the Element with Cypress ID "add-plan-select autocomplete"
    Then the Element with Cypress ID "badge-added" should exist
    And the Element with Cypress ID "button-remove-plan" should exist

  Scenario: Should be possible to remove plan
    Given the User "MMAdmin001" is Signed In
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding OauthClient Settings "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001AndPriceFree" for Service Provider "001" with query params "limit=10&offset=0&include_in_self_service=true&sort=agreement_type.self_service_order:asc&disable_pagination=true"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-pricing-page"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-pricing-button"
    And the User clicks on the Element with Cypress ID "self-service-checkbox"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-remove-plan"
    And the Element with Cypress ID "remove-plan-dialog" should exist
    And the User clicks on the Element with Cypress ID "button-cancel-remove-plan"
    And the Element with Cypress ID "remove-plan-dialog" should NOT exist
    And the Element with Cypress ID "remove-plan-dialog" should NOT exist
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-remove-plan"
    And the User clicks on the Element with Cypress ID "button-confirm-remove-plan"
    Then the Element with Cypress ID "name-3fa85f64-5717-4562-b3fc-2c963f66afa7" should NOT exist

  Scenario: Should be possible to go to plan details page by actions button
    Given the User "MMAdmin001" is Signed In
    And the feature flag "pricing" is enabled
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding OauthClient Settings "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_IncludedInSelfService" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_IncludedInSelfService" for Service Provider "001" with query params "limit=10&offset=0&include_in_self_service=true&sort=agreement_type.self_service_order:asc&disable_pagination=true"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-pricing-page"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003" for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    When the User clicks on the Element with Cypress ID "actions-dropdown-3fa85f64-5717-4562-b3fc-2c963f66afa7-item-go-to-plan"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"

  Scenario: Should be possible to go to plan details page by link
    Given the User "MMAdmin001" is Signed In
    And the feature flag "pricing" is enabled
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding OauthClient Settings "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_IncludedInSelfService" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_IncludedInSelfService" for Service Provider "001" with query params "limit=10&offset=0&include_in_self_service=true&sort=agreement_type.self_service_order:asc&disable_pagination=true"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-pricing-page"
    And the intercepted requests have resolved
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Service Provider "001"
    And the Configuration GET Legal Document Types request has been intercepted to return Legal Document Types "001" for Agreement Type "003" for for Service Provider "001"
    And the Configuration GET Agreement Type request has been intercepted to return Agreement Type "003_IncludedInSelfService" for Service Provider "001"
    And the Configuration GET Policy Types request has been intercepted to return Policy Types "001" for Service Provider "001"
    When the User clicks on the Element with Cypress ID "name-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the intercepted requests have resolved
    Then the User should be redirected to "/sp/4a6f01d0-f3c6-4923-ad98-112d6d97355b/plans/3fa85f64-5717-4562-b3fc-2c963f66afa7"

  Scenario: Should successfully add Plan
    Given the User "MMAdmin001" is Signed In
    And the feature flag "pricing" is enabled
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding OauthClient Settings "001" request for Service Provider "001" has been intercepted
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "no-results" for Service Provider "001" with query params "limit=10&offset=0&include_in_self_service=true&sort=agreement_type.self_service_order:asc&disable_pagination=true"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-pricing-page"
    And the intercepted requests have resolved
    And the User clicks on the Element with Cypress ID "edit-pricing-button"
    And the User clicks on the Element with Cypress ID "self-service-checkbox"
    And the User clicks on the Element with Cypress ID "button-add-plan-card"
    And the User clicks on the Element with Cypress ID "add-plan-select autocomplete"
    And the User clicks on the Element with Cypress ID "mm-autocomplete-option-3fa85f64-5717-4562-b3fc-2c963f66afa7"
    And the User clicks on the Element with Cypress ID "button-confirm-add-plan"
    And the Configuration PATCH Agreement Type request has been intercepted to update Agreement Type "003" and return Agreement Type "003_WithDefaultPolicy001AndPriceFree" for Service Provider "001"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001AndPriceFree" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001AndPriceFree" for Service Provider "001" with query params "limit=10&offset=0&include_in_self_service=true&sort=agreement_type.self_service_order:asc&disable_pagination=true"
    And the Onboarding OauthClient Settings "001" request for Service Provider "001" has been intercepted to update the settings
    When the User clicks on the Element with Cypress ID "save-pricing-button"
    And the intercepted requests have resolved
    Then the Element with Cypress ID "plans-table name-3fa85f64-5717-4562-b3fc-2c963f66afa7" contains the text as "Agreement Type 003"

  Scenario: Should be possible to open Dialog Preview Plan with default info
    Given the User "MMAdmin001" is Signed In
    And the feature flag "pricing" is enabled
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "001"
    And the Onboarding OauthClient Settings "002" request for Service Provider "001" has been intercepted
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001AndPriceFree" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001AndPriceFree" for Service Provider "001" with query params "limit=10&offset=0&include_in_self_service=true&sort=agreement_type.self_service_order:asc&disable_pagination=true"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-pricing-page"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "preview-pricing-button"
    Then the Element with Cypress ID "preview-plan-dialog dialog-title" should have the text as "Select a Service Provider 001 Plan"
    And the Element with Cypress ID "preview-plan-dialog index-0 product-name" should have the text as "Agreement Type 003"
    And the Element with Cypress ID "preview-plan-dialog index-0 pricing-card-message" should have the text as " Agreement Type 003 Description"
    And the Element with Cypress ID "preview-plan-dialog index-0 pricing-type" should have the text as "/Free"
#    And the Element with Cypress ID "preview-plan-dialog index-0 pricing-card-included-products" should exist
    And the Element with Cypress ID "preview-plan-dialog index-1 pricing-card-included-products" should NOT exist
    And the Element with Cypress ID "preview-plan-dialog index-2 pricing-card-included-products" should NOT exist
    And the User clicks on the Element with Cypress ID "dialog-close-button"
    And the Element with Cypress ID "preview-plan-dialog" should NOT exist

  Scenario: Should be possible to open Dialog Preview Plan with configs from branding
    Given the User "MMAdmin001" is Signed In
    And the feature flag "pricing" is enabled
    And the IAM User @me request has been intercepted to return the User "MMAdmin001"
    And the Configuration GET OAuth Clients request has been intercepted to return the OAuth Clients "001" for Service Provider "001"
    And the User navigates to "/sp/configuration"
    And the intercepted requests have resolved
    And the IAM Service Providers request has been intercepted to return the Service Provider "003"
    And the Onboarding OauthClient Settings "002" request for Service Provider "001" has been intercepted
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001AndPriceFree" for Service Provider "001" with query params "category=SUBSCRIPTION&limit=10&offset=0"
    And the Configuration GET Agreement types request has been intercepted to return Agreement Types "003_WithDefaultPolicy001AndPriceFree" for Service Provider "001" with query params "limit=10&offset=0&include_in_self_service=true&sort=agreement_type.self_service_order:asc&disable_pagination=true"
    And the Policies Agreement Type request has been intercepted to return the Agreement type "003" for Service Provider "001"
    And the User clicks on the Element with Cypress ID "tab-item-pricing-page"
    And the intercepted requests have resolved
    When the User clicks on the Element with Cypress ID "preview-pricing-button"
    Then the Element with Cypress ID "dialog-title" should have the text as "Select a Service Provider 003 Plan"
    And the Element with Cypress ID "pricing-card-button" should have the color "rgb(235, 20, 5)"
