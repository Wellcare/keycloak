# Database Schema

This document describes the database schema for the Keycloak Wellcare system using **DBML** (Database Markup Language).

## Overview

The database consists of Keycloak's standard tables plus custom tables for phone authentication functionality. The main custom table is `PHONE_MESSAGE_TOKEN_CODE` which stores SMS verification codes and their metadata.

## Schema Definition

```dbml
// Keycloak Wellcare Database Schema
// Docs: https://dbml.dbdiagram.io/docs

// Custom Phone Authentication Tables
Table PHONE_MESSAGE_TOKEN_CODE {
  id varchar [primary key, note: "Unique identifier for the token code"]
  realm_id varchar [not null, note: "Keycloak realm identifier"]
  phone_number varchar [not null, note: "Phone number in international format"]
  type varchar [not null, note: "Type of token: VERIFY, AUTH, REGISTRATION, RESET, OTP"]
  code varchar [not null, note: "The actual verification code sent via SMS"]
  created_at timestamp [not null, note: "When the code was created"]
  expires_at timestamp [not null, note: "When the code expires"]
  confirmed boolean [not null, note: "Whether the code has been verified"]
  by_whom varchar [note: "User who confirmed the code"]
  ip varchar [note: "IP address of the request"]
  port integer [note: "Port of the request"]
  host varchar [note: "Host of the request"]

  indexes {
    (realm_id, phone_number, type) [note: "Index for querying ongoing processes"]
    (realm_id, phone_number, created_at) [note: "Index for rate limiting queries"]
    (realm_id, ip, created_at) [note: "Index for source-based rate limiting"]
    expires_at [note: "Index for cleanup of expired codes"]
  }
}

// Keycloak Standard Tables (Core Authentication)
Table USER_ENTITY {
  id varchar [primary key, note: "Unique user identifier"]
  email varchar [note: "User email address"]
  email_constraint varchar [unique, note: "Email constraint for uniqueness"]
  email_verified boolean [note: "Whether email is verified"]
  enabled boolean [note: "Whether user account is enabled"]
  federation_link varchar [note: "Federation provider link"]
  first_name varchar [note: "User first name"]
  last_name varchar [note: "User last name"]
  realm_id varchar [not null, note: "Keycloak realm identifier"]
  username varchar [note: "Username for login"]
  created_timestamp bigint [note: "Account creation timestamp"]
  service_account_client_link varchar [note: "Service account client link"]
  not_before integer [note: "Not before timestamp for tokens"]

  indexes {
    realm_id [note: "Index for realm-based queries"]
    email_constraint [note: "Index for email uniqueness"]
    username [note: "Index for username lookups"]
  }
}

Table USER_ATTRIBUTE {
  id varchar [primary key, note: "Unique attribute identifier"]
  name varchar [not null, note: "Attribute name"]
  value text [note: "Attribute value"]
  user_id varchar [not null, note: "User this attribute belongs to"]

  indexes {
    user_id [note: "Index for user attribute queries"]
    (user_id, name) [note: "Index for specific user attributes"]
  }
}

Table CREDENTIAL {
  id varchar [primary key, note: "Unique credential identifier"]
  created_date bigint [note: "Credential creation date"]
  credential_data text [note: "Serialized credential data"]
  priority integer [note: "Credential priority"]
  secret_data text [note: "Encrypted secret data"]
  user_id varchar [not null, note: "User this credential belongs to"]
  type varchar [note: "Credential type (password, otp, etc.)"]

  indexes {
    user_id [note: "Index for user credential queries"]
    (user_id, type) [note: "Index for specific credential types"]
  }
}

Table REALM {
  id varchar [primary key, note: "Unique realm identifier"]
  access_code_lifespan integer [note: "Access code lifespan in seconds"]
  access_code_lifespan_login integer [note: "Access code lifespan for login"]
  access_code_lifespan_user_action integer [note: "Access code lifespan for user actions"]
  access_token_lifespan integer [note: "Access token lifespan in seconds"]
  access_token_lifespan_for_implicit_flow integer [note: "Access token lifespan for implicit flow"]
  account_theme varchar [note: "Account management theme"]
  action_token_generated_by_user_lifespan integer [note: "Action token lifespan"]
  admin_events_details_enabled boolean [note: "Whether admin events details are enabled"]
  admin_events_enabled boolean [note: "Whether admin events are enabled"]
  admin_theme varchar [note: "Admin console theme"]
  attributes text [note: "Realm attributes as JSON"]
  browser_flow varchar [note: "Browser authentication flow"]
  browser_security_headers text [note: "Browser security headers"]
  brute_force_detection boolean [note: "Whether brute force detection is enabled"]
  client_authentication_flow varchar [note: "Client authentication flow"]
  client_offline_session_idle integer [note: "Client offline session idle timeout"]
  client_offline_session_max_lifespan integer [note: "Client offline session max lifespan"]
  client_session_idle integer [note: "Client session idle timeout"]
  client_session_max_lifespan integer [note: "Client session max lifespan"]
  default_signature_algorithm varchar [note: "Default signature algorithm"]
  direct_grant_flow varchar [note: "Direct grant flow"]
  display_name varchar [note: "Realm display name"]
  display_name_html varchar [note: "Realm display name HTML"]
  docker_authentication_flow varchar [note: "Docker authentication flow"]
  duplicate_emails_allowed boolean [note: "Whether duplicate emails are allowed"]
  edit_username_allowed boolean [note: "Whether username editing is allowed"]
  email_theme varchar [note: "Email theme"]
  enabled boolean [note: "Whether realm is enabled"]
  enabled_event_types text [note: "Enabled event types"]
  events_enabled boolean [note: "Whether events are enabled"]
  events_expiration bigint [note: "Events expiration timestamp"]
  events_listeners text [note: "Event listeners configuration"]
  failure_factor integer [note: "Failure factor for brute force detection"]
  login_theme varchar [note: "Login theme"]
  login_with_email_allowed boolean [note: "Whether login with email is allowed"]
  max_delta_time_seconds integer [note: "Maximum delta time in seconds"]
  max_failure_wait_seconds integer [note: "Maximum failure wait time"]
  minimum_quick_login_wait_seconds integer [note: "Minimum quick login wait time"]
  name varchar [unique, note: "Realm name"]
  not_before integer [note: "Not before timestamp"]
  offline_session_idle_timeout integer [note: "Offline session idle timeout"]
  offline_session_max_lifespan integer [note: "Offline session max lifespan"]
  offline_session_max_lifespan_enabled boolean [note: "Whether offline session max lifespan is enabled"]
  otp_policy_algorithm varchar [note: "OTP policy algorithm"]
  otp_policy_digits integer [note: "OTP policy digits"]
  otp_policy_initial_counter integer [note: "OTP policy initial counter"]
  otp_policy_look_ahead_window integer [note: "OTP policy look ahead window"]
  otp_policy_period integer [note: "OTP policy period"]
  otp_policy_type varchar [note: "OTP policy type"]
  password_policy text [note: "Password policy configuration"]
  permanent_lockout boolean [note: "Whether permanent lockout is enabled"]
  quick_login_check_milli_seconds bigint [note: "Quick login check interval"]
  realm_cache_enabled boolean [note: "Whether realm cache is enabled"]
  refresh_token_max_reuse integer [note: "Refresh token max reuse count"]
  registration_allowed boolean [note: "Whether registration is allowed"]
  registration_email_as_username boolean [note: "Whether email can be used as username"]
  registration_flow varchar [note: "Registration flow"]
  remember_me boolean [note: "Whether remember me is enabled"]
  reset_credentials_flow varchar [note: "Reset credentials flow"]
  reset_password_allowed boolean [note: "Whether password reset is allowed"]
  revoke_refresh_token boolean [note: "Whether refresh tokens are revoked"]
  sso_session_idle_timeout integer [note: "SSO session idle timeout"]
  sso_session_idle_timeout_remember_me integer [note: "SSO session idle timeout for remember me"]
  sso_session_max_lifespan integer [note: "SSO session max lifespan"]
  sso_session_max_lifespan_remember_me integer [note: "SSO session max lifespan for remember me"]
  ssl_required varchar [note: "SSL requirement level"]
  verify_email boolean [note: "Whether email verification is required"]
  wait_increment_seconds integer [note: "Wait increment for brute force detection"]
  web_authn_policy_acceptable_aaguids text [note: "WebAuthn policy acceptable AAGUIDs"]
  web_authn_policy_attestation_conveyance_preference varchar [note: "WebAuthn policy attestation conveyance preference"]
  web_authn_policy_authenticator_attachment varchar [note: "WebAuthn policy authenticator attachment"]
  web_authn_policy_avoid_same_authenticator_register boolean [note: "WebAuthn policy avoid same authenticator register"]
  web_authn_policy_create_timeout integer [note: "WebAuthn policy create timeout"]
  web_authn_policy_require_resident_key varchar [note: "WebAuthn policy require resident key"]
  web_authn_policy_resident_key varchar [note: "WebAuthn policy resident key"]
  web_authn_policy_rp_entity_name varchar [note: "WebAuthn policy RP entity name"]
  web_authn_policy_rp_id varchar [note: "WebAuthn policy RP ID"]
  web_authn_policy_signature_algorithms text [note: "WebAuthn policy signature algorithms"]
  web_authn_policy_user_verification_requirement varchar [note: "WebAuthn policy user verification requirement"]

  indexes {
    name [note: "Index for realm name lookups"]
    enabled [note: "Index for enabled realms"]
  }
}

// Relationships
Ref: PHONE_MESSAGE_TOKEN_CODE.realm_id > REALM.id
Ref: USER_ATTRIBUTE.user_id > USER_ENTITY.id
Ref: CREDENTIAL.user_id > USER_ENTITY.id
Ref: USER_ENTITY.realm_id > REALM.id
```

## Table Descriptions

### PHONE_MESSAGE_TOKEN_CODE

The main custom table for storing SMS verification codes. Each record represents a single SMS code sent to a user's phone number for authentication purposes.

**Key Features:**

- Supports multiple token types (verification, authentication, registration, reset, OTP)
- Includes rate limiting metadata (IP, host, timestamps)
- Tracks confirmation status and who confirmed the code
- Automatic expiration handling

### USER_ENTITY

Standard Keycloak user table storing user account information.

### USER_ATTRIBUTE

Stores custom user attributes as key-value pairs.

### CREDENTIAL

Stores user credentials including passwords, OTP secrets, and other authentication factors.

### REALM

Stores Keycloak realm configuration including authentication flows, themes, and security policies.

## Indexes and Performance

The schema includes several strategic indexes to optimize common query patterns:

1. **Token Code Queries**: Indexes on `(realm_id, phone_number, type)` for finding active verification codes
2. **Rate Limiting**: Indexes on `(realm_id, phone_number, created_at)` and `(realm_id, ip, created_at)` for rate limiting enforcement
3. **Cleanup**: Index on `expires_at` for removing expired codes
4. **User Lookups**: Indexes on `username`, `email_constraint`, and `realm_id` for user queries

## Data Retention

- **Token Codes**: Automatically expire based on `expires_at` timestamp
- **Users**: Retained according to realm configuration
- **Events**: Configurable retention period via `events_expiration`

## Security Considerations

- All sensitive data (passwords, OTP secrets) are encrypted in the database
- Token codes have short lifespans to minimize security risks
- Rate limiting is enforced at both phone number and IP address levels
- Audit trails are maintained for security events
