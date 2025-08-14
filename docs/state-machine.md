# State Machines

This document describes the state machines and authentication flows in the Keycloak Wellcare system using **Mermaid.js** state diagrams.

## Overview

The system implements several state machines for different authentication scenarios. Each state machine represents a specific authentication flow with defined states, transitions, and triggers.

## SMS Token Code State Machine

This state machine tracks the lifecycle of SMS verification codes from creation to expiration or confirmation.

```mermaid
stateDiagram-v2
    [*] --> Created : Generate SMS Code

    Created --> Pending : Code Sent to User
    Created --> Expired : Timeout (5 minutes)

    Pending --> Confirmed : User Enters Valid Code
    Pending --> Expired : Timeout (5 minutes)
    Pending --> Invalid : User Enters Wrong Code

    Invalid --> Pending : User Retries
    Invalid --> Expired : Max Retries Exceeded

    Confirmed --> [*] : Code Used Successfully
    Expired --> [*] : Code No Longer Valid

    note right of Created
        - Code generated
        - Stored in database
        - Rate limits checked
    end note

    note right of Pending
        - Waiting for user input
        - Code can be retried
        - Expiration timer active
    end note

    note right of Confirmed
        - Code validated
        - User authenticated
        - Code marked as used
    end note

    note right of Expired
        - Code no longer valid
        - User must request new code
        - Cleanup process triggered
    end note
```

## User Registration State Machine

This state machine tracks the user registration process with phone verification.

```mermaid
stateDiagram-v2
    [*] --> Initiated : User Starts Registration

    Initiated --> PhoneEntered : User Enters Phone Number
    Initiated --> Failed : Invalid Phone Format

    PhoneEntered --> CodeSent : Registration SMS Sent
    PhoneEntered --> Failed : Phone Already Registered

    CodeSent --> CodeEntered : User Enters SMS Code
    CodeSent --> Expired : SMS Code Expired

    CodeEntered --> Validated : Code Verification Successful
    CodeEntered --> InvalidCode : Wrong Code Entered

    InvalidCode --> CodeEntered : User Retries
    InvalidCode --> Expired : Max Retries Exceeded

    Validated --> UserCreated : User Account Created
    Validated --> Failed : Account Creation Error

    UserCreated --> Completed : Registration Successful
    Expired --> Failed : Registration Timeout

    Failed --> [*] : Registration Failed
    Completed --> [*] : Registration Complete

    note right of Initiated
        - Registration form displayed
        - Phone number validation
    end note

    note right of CodeSent
        - SMS sent to phone
        - Rate limiting applied
        - Expiration timer started
    end note

    note right of Validated
        - SMS code verified
        - Phone number confirmed
        - User data validated
    end note

    note right of UserCreated
        - User account created
        - Phone attribute set
        - Welcome email sent
    end note
```

## Phone Authentication State Machine

This state machine tracks the phone-based authentication flow.

```mermaid
stateDiagram-v2
    [*] --> PhoneSubmitted : User Submits Phone

    PhoneSubmitted --> Validated : Phone Number Valid
    PhoneSubmitted --> Failed : Invalid Phone Format

    Validated --> CodeSent : Authentication SMS Sent
    Validated --> Failed : Phone Not Registered

    CodeSent --> CodeEntered : User Enters SMS Code
    CodeSent --> Expired : SMS Code Expired

    CodeEntered --> Authenticated : Code Verification Successful
    CodeEntered --> InvalidCode : Wrong Code Entered

    InvalidCode --> CodeEntered : User Retries
    InvalidCode --> Expired : Max Retries Exceeded

    Authenticated --> UserFound : User Account Found
    Authenticated --> UserCreated : Auto-create User (if enabled)

    UserFound --> LoggedIn : Authentication Successful
    UserCreated --> LoggedIn : User Created and Logged In

    Expired --> Failed : Authentication Timeout

    Failed --> [*] : Authentication Failed
    LoggedIn --> [*] : User Successfully Authenticated

    note right of PhoneSubmitted
        - Phone number format check
        - International format required
    end note

    note right of CodeSent
        - Authentication SMS sent
        - Rate limiting enforced
        - Expiration timer active
    end note

    note right of Authenticated
        - SMS code verified
        - User identity confirmed
        - Session created
    end note

    note right of LoggedIn
        - Access token issued
        - Refresh token provided
        - User session active
    end note
```

## Password Reset State Machine

This state machine tracks the password reset process using phone verification.

```mermaid
stateDiagram-v2
    [*] --> ResetRequested : User Requests Password Reset

    ResetRequested --> PhoneValidated : Phone Number Valid
    ResetRequested --> Failed : Invalid Phone Format

    PhoneValidated --> UserFound : User Account Found
    PhoneValidated --> Failed : Phone Not Registered

    UserFound --> CodeSent : Reset SMS Sent
    UserFound --> Failed : User Account Disabled

    CodeSent --> CodeEntered : User Enters SMS Code
    CodeSent --> Expired : SMS Code Expired

    CodeEntered --> CodeValidated : Code Verification Successful
    CodeEntered --> InvalidCode : Wrong Code Entered

    InvalidCode --> CodeEntered : User Retries
    InvalidCode --> Expired : Max Retries Exceeded

    CodeValidated --> PasswordEntered : User Enters New Password
    CodeValidated --> Failed : Code Validation Error

    PasswordEntered --> PasswordValidated : Password Meets Requirements
    PasswordEntered --> Failed : Password Too Weak

    PasswordValidated --> PasswordUpdated : Password Successfully Updated
    PasswordUpdated --> Completed : Reset Process Complete

    Expired --> Failed : Reset Timeout

    Failed --> [*] : Reset Failed
    Completed --> [*] : Password Reset Complete

    note right of ResetRequested
        - Reset form displayed
        - Phone number input
    end note

    note right of CodeSent
        - Reset SMS sent
        - Rate limiting applied
        - Expiration timer started
    end note

    note right of CodeValidated
        - SMS code verified
        - User identity confirmed
        - Reset token issued
    end note

    note right of PasswordUpdated
        - New password saved
        - Old sessions invalidated
        - Success notification sent
    end note
```

## Two-Factor Authentication (2FA) State Machine

This state machine tracks the SMS-based two-factor authentication flow.

```mermaid
stateDiagram-v2
    [*] --> FirstFactor : First Factor Completed

    FirstFactor --> SecondFactor : Username/Password Valid
    FirstFactor --> Failed : First Factor Failed

    SecondFactor --> CodeSent : SMS OTP Sent
    SecondFactor --> Failed : Phone Not Configured

    CodeSent --> CodeEntered : User Enters OTP Code
    CodeSent --> Expired : OTP Code Expired

    CodeEntered --> CodeValidated : OTP Verification Successful
    CodeEntered --> InvalidCode : Wrong OTP Code

    InvalidCode --> CodeEntered : User Retries
    InvalidCode --> Expired : Max Retries Exceeded

    CodeValidated --> Authenticated : 2FA Complete
    CodeValidated --> Failed : OTP Validation Error

    Expired --> Failed : 2FA Timeout

    Failed --> [*] : 2FA Failed
    Authenticated --> [*] : User Fully Authenticated

    note right of FirstFactor
        - Username/password login
        - Account validation
        - 2FA requirement check
    end note

    note right of CodeSent
        - OTP SMS sent
        - Rate limiting applied
        - Expiration timer active
    end note

    note right of CodeValidated
        - OTP code verified
        - Second factor complete
        - Full authentication granted
    end note

    note right of Authenticated
        - Access token issued
        - 2FA session created
        - User fully authenticated
    end note
```

## State Transitions Table

| Trigger            | From State      | To State  | Conditions                   |
| ------------------ | --------------- | --------- | ---------------------------- |
| Generate Code      | [*]             | Created   | Rate limit not exceeded      |
| Send SMS           | Created         | Pending   | SMS provider available       |
| Timeout            | Created/Pending | Expired   | 5 minutes elapsed            |
| Enter Valid Code   | Pending         | Confirmed | Code matches and not expired |
| Enter Invalid Code | Pending         | Invalid   | Code doesn't match           |
| Retry Code         | Invalid         | Pending   | Under max retry limit        |
| Max Retries        | Invalid         | Expired   | Retry limit exceeded         |
| Use Code           | Confirmed       | [*]       | Code consumed                |
| Cleanup            | Expired         | [*]       | Expired code removed         |

## State Metadata

Each state includes the following metadata:

### Timestamps

- `created_at`: When the state was first entered
- `updated_at`: When the state was last modified
- `expires_at`: When the state will expire (if applicable)

### User Context

- `user_id`: Associated user (if applicable)
- `phone_number`: Phone number involved in the flow
- `ip_address`: Client IP address for security tracking

### Security Information

- `session_id`: Associated session identifier
- `correlation_id`: Request correlation for tracing
- `rate_limit_key`: Key used for rate limiting

## Error Handling

Each state machine includes comprehensive error handling:

1. **Timeout Handling**: Automatic transition to failed/expired states
2. **Rate Limiting**: Prevention of state transitions when limits exceeded
3. **Invalid Input**: Graceful handling of malformed requests
4. **Provider Failures**: Fallback mechanisms for SMS service failures
5. **Database Errors**: Rollback mechanisms for failed state persistence

## Security Considerations

1. **State Validation**: All state transitions are validated for security
2. **Session Management**: Proper session handling throughout state changes
3. **Audit Logging**: All state transitions are logged for security monitoring
4. **Rate Limiting**: Prevents abuse of state transition triggers
5. **Expiration**: Automatic cleanup of expired states to prevent resource exhaustion
