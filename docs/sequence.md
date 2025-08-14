# System Workflows

This document describes the key system workflows and interactions between services using **Mermaid.js** sequence diagrams.

## Overview

The Keycloak Wellcare system integrates with multiple SMS providers and handles various authentication flows. This document covers the confirmed workflows found in the codebase.

## SMS Code Request Flow

This workflow shows how a user requests an SMS verification code through the REST API.

```mermaid
sequenceDiagram
    participant Client
    participant Keycloak as Keycloak API
    participant PhoneProvider as Phone Provider
    participant SMSService as SMS Service
    participant Database as Database

    Client->>Keycloak: GET /realms/{realm}/sms/verification-code?phoneNumber={phone}
    Note over Keycloak: Validate phone number format
    Keycloak->>PhoneProvider: sendTokenCode(phoneNumber, type, kind)
    Note over PhoneProvider: Check rate limits
    PhoneProvider->>Database: Query existing codes for rate limiting
    Database-->>PhoneProvider: Return count of recent codes

    alt Rate limit exceeded
        PhoneProvider-->>Keycloak: Throw rate limit exception
        Keycloak-->>Client: 429 Too Many Requests
    else Rate limit OK
        PhoneProvider->>PhoneProvider: Generate random code
        PhoneProvider->>Database: Store TokenCode record
        Database-->>PhoneProvider: Confirm storage

        PhoneProvider->>SMSService: Send SMS with code
        Note over SMSService: Wellcare/Twilio/AWS SNS/etc.
        SMSService-->>PhoneProvider: SMS sent confirmation

        PhoneProvider-->>Keycloak: Return expires_in seconds
        Keycloak-->>Client: 200 OK {"expires_in": 300}
    end
```

## SMS Code Verification Flow

This workflow shows how a user verifies an SMS code they received.

```mermaid
sequenceDiagram
    participant Client
    participant Keycloak as Keycloak API
    participant PhoneProvider as Phone Provider
    participant Database as Database

    Client->>Keycloak: POST /realms/{realm}/sms/verification-code
    Note over Client: Authorization: Bearer {token}
    Note over Client: phoneNumber={phone}&code={code}

    Keycloak->>Keycloak: Validate Bearer token
    Keycloak->>PhoneProvider: validateCode(user, phoneNumber, code)

    PhoneProvider->>Database: Query TokenCode by phone, type, code
    Database-->>PhoneProvider: Return TokenCode record

    alt Code not found or expired
        PhoneProvider-->>Keycloak: Throw validation exception
        Keycloak-->>Client: 400 Bad Request
    else Code valid
        PhoneProvider->>Database: Mark code as confirmed
        Database-->>PhoneProvider: Update confirmed
        PhoneProvider-->>Keycloak: Validation successful
        Keycloak-->>Client: 204 No Content
    end
```

## Phone Authentication Flow

This workflow shows the direct grant authentication using phone number and SMS code.

```mermaid
sequenceDiagram
    participant Client
    participant Keycloak as Keycloak API
    participant PhoneProvider as Phone Provider
    participant Database as Database
    participant UserService as User Service

    Client->>Keycloak: POST /realms/{realm}/protocol/openid-connect/token
    Note over Client: grant_type=password<br/>client_id={client}<br/>username={phone}<br/>password={code}

    Keycloak->>PhoneProvider: authenticate(phoneNumber, code)
    PhoneProvider->>Database: Query TokenCode by phone and code
    Database-->>PhoneProvider: Return TokenCode record

    alt Code invalid or expired
        PhoneProvider-->>Keycloak: Authentication failed
        Keycloak-->>Client: 401 Unauthorized
    else Code valid
        PhoneProvider->>UserService: Find user by phone number
        UserService-->>PhoneProvider: Return user or null

        alt User not found
            Note over PhoneProvider: Auto-create user if configured
            PhoneProvider->>UserService: Create user with phone number
            UserService-->>PhoneProvider: New user created
        end

        PhoneProvider->>Database: Mark code as confirmed
        Database-->>PhoneProvider: Update confirmed

        PhoneProvider-->>Keycloak: Authentication successful
        Keycloak-->>Client: 200 OK {access_token, refresh_token}
    end
```

## User Registration with Phone Flow

This workflow shows how a user registers with phone number verification.

```mermaid
sequenceDiagram
    participant Client
    participant Keycloak as Keycloak API
    participant PhoneProvider as Phone Provider
    participant SMSService as SMS Service
    participant Database as Database
    participant UserService as User Service

    Client->>Keycloak: GET /realms/{realm}/sms/registration-code?phoneNumber={phone}
    Keycloak->>PhoneProvider: sendTokenCode(phoneNumber, REGISTRATION)
    PhoneProvider->>Database: Check if phone already registered
    Database-->>PhoneProvider: Return existing user or null

    alt Phone already registered
        PhoneProvider-->>Keycloak: Phone already exists
        Keycloak-->>Client: 409 Conflict
    else Phone available
        PhoneProvider->>PhoneProvider: Generate registration code
        PhoneProvider->>Database: Store TokenCode record
        Database-->>PhoneProvider: Confirm storage

        PhoneProvider->>SMSService: Send registration SMS
        SMSService-->>PhoneProvider: SMS sent confirmation
        PhoneProvider-->>Keycloak: Return expires_in
        Keycloak-->>Client: 200 OK {"expires_in": 300}
    end

    Note over Client: User receives SMS and enters code
    Client->>Keycloak: POST /realms/{realm}/users
    Note over Client: Include phone number and verification code
    Keycloak->>PhoneProvider: validateCode(user, phoneNumber, code)
    PhoneProvider->>Database: Verify registration code
    Database-->>PhoneProvider: Return TokenCode record

    alt Code valid
        PhoneProvider->>UserService: Create user account
        UserService-->>PhoneProvider: User created
        PhoneProvider->>Database: Mark code as confirmed
        Keycloak-->>Client: 201 Created
    else Code invalid
        PhoneProvider-->>Keycloak: Invalid code
        Keycloak-->>Client: 400 Bad Request
    end
```

## Password Reset with Phone Flow

This workflow shows how a user resets their password using phone verification.

```mermaid
sequenceDiagram
    participant Client
    participant Keycloak as Keycloak API
    participant PhoneProvider as Phone Provider
    participant SMSService as SMS Service
    participant Database as Database
    participant UserService as User Service

    Client->>Keycloak: GET /realms/{realm}/sms/reset-code?phoneNumber={phone}
    Keycloak->>PhoneProvider: sendTokenCode(phoneNumber, RESET)
    PhoneProvider->>UserService: Find user by phone number
    UserService-->>PhoneProvider: Return user or null

    alt User not found
        PhoneProvider-->>Keycloak: User not found
        Keycloak-->>Client: 404 Not Found
    else User found
        PhoneProvider->>PhoneProvider: Generate reset code
        PhoneProvider->>Database: Store TokenCode record
        Database-->>PhoneProvider: Confirm storage

        PhoneProvider->>SMSService: Send reset SMS
        SMSService-->>PhoneProvider: SMS sent confirmation
        PhoneProvider-->>Keycloak: Return expires_in
        Keycloak-->>Client: 200 OK {"expires_in": 300}
    end

    Note over Client: User receives SMS and enters new password
    Client->>Keycloak: POST /realms/{realm}/users/{user-id}/reset-password
    Note over Client: Include reset code and new password
    Keycloak->>PhoneProvider: validateCode(user, phoneNumber, code)
    PhoneProvider->>Database: Verify reset code
    Database-->>PhoneProvider: Return TokenCode record

    alt Code valid
        PhoneProvider->>UserService: Update user password
        UserService-->>PhoneProvider: Password updated
        PhoneProvider->>Database: Mark code as confirmed
        Keycloak-->>Client: 200 OK
    else Code invalid
        PhoneProvider-->>Keycloak: Invalid code
        Keycloak-->>Client: 400 Bad Request
    end
```

## SMS Provider Integration Flow

This workflow shows how the system integrates with different SMS providers.

```mermaid
sequenceDiagram
    participant Keycloak as Keycloak
    participant SMSProvider as SMS Provider SPI
    participant WellcareSMS as Wellcare SMS
    participant TwilioSMS as Twilio SMS
    participant AWSSNS as AWS SNS
    participant AliyunSMS as Aliyun SMS

    Keycloak->>SMSProvider: sendMessage(phoneNumber, message)
    Note over SMSProvider: Determine provider from config

    alt Provider: Wellcare
        SMSProvider->>WellcareSMS: POST /v1/messages
        Note over WellcareSMS: Username/password auth
        WellcareSMS-->>SMSProvider: SMS sent confirmation
    else Provider: Twilio
        SMSProvider->>TwilioSMS: POST /2010-04-01/Accounts/{sid}/Messages.json
        Note over TwilioSMS: Account SID/Auth Token
        TwilioSMS-->>SMSProvider: SMS sent confirmation
    else Provider: AWS SNS
        SMSProvider->>AWSSNS: POST /publish
        Note over AWSSNS: AWS credentials
        AWSSNS-->>SMSProvider: SMS sent confirmation
    else Provider: Aliyun
        SMSProvider->>AliyunSMS: POST /dysmsapi.aliyuncs.com
        Note over AliyunSMS: Access Key/Secret
        AliyunSMS-->>SMSProvider: SMS sent confirmation
    end

    SMSProvider-->>Keycloak: Return success/failure
```

## Configuration Sources

The system uses the following configuration sources that affect the workflows:

### Environment Variables

- `KK_TO_RMQ_URL`: RabbitMQ connection URL (configured but not used in current codebase)
- `KK_TO_RMQ_PORT`: RabbitMQ port
- `KK_TO_RMQ_EXCHANGE`: RabbitMQ exchange name
- `KK_TO_RMQ_USERNAME`: RabbitMQ username
- `KK_TO_RMQ_PASSWORD`: RabbitMQ password
- `KK_TO_RMQ_USE_TLS`: RabbitMQ TLS flag

### SMS Provider Configuration

- `--spi-phone-default-service`: Default SMS provider (wellcare, twilio, aws-sns, etc.)
- `--spi-message-sender-service-{provider}-username`: Provider username
- `--spi-message-sender-service-{provider}-password`: Provider password
- `--spi-message-sender-service-{provider}-url`: Provider API URL
- `--spi-message-sender-service-{provider}-from`: Sender identifier

### Rate Limiting Configuration

- `--spi-phone-target-hour-maximum`: Maximum codes per hour per phone
- `--spi-phone-source-hour-maximum`: Maximum codes per hour per IP
- `--spi-phone-otp-expires`: OTP expiration time in seconds

## Error Handling

All workflows include comprehensive error handling:

1. **Rate Limiting**: Returns 429 Too Many Requests when limits exceeded
2. **Invalid Phone Numbers**: Returns 400 Bad Request for malformed numbers
3. **Expired Codes**: Returns 400 Bad Request for expired verification codes
4. **Authentication Failures**: Returns 401 Unauthorized for invalid credentials
5. **User Not Found**: Returns 404 Not Found when phone number not registered
6. **Duplicate Registration**: Returns 409 Conflict for existing phone numbers
7. **SMS Provider Errors**: Returns 500 Internal Server Error for SMS service failures
