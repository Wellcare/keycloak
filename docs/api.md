# API Reference

This document provides a complete reference for the Keycloak Wellcare REST API endpoints.

## Base URL

All API endpoints are relative to the Keycloak server URL:

```
http://localhost:8080
```

## Authentication

Most endpoints require authentication using Bearer tokens. Include the token in the Authorization header:

```
Authorization: Bearer <your_access_token>
```

## Endpoints

### SMS Verification Code

#### Send Verification Code

**GET** `/realms/{realm}/sms/verification-code`

Sends an SMS verification code to the specified phone number.

**Parameters:**

- `phoneNumber` (query, required): Phone number in international format (e.g., +1234567890)
- `kind` (query, optional): Additional context for the verification

**Authentication:** Not required

**Example Request:**

```bash
curl -X GET "http://localhost:8080/realms/wellcare/sms/verification-code?phoneNumber=+1234567890"
```

**Example Response:**

```json
{
  "expires_in": 300
}
```

**Response Codes:**

- `200 OK`: Code sent successfully
- `400 Bad Request`: Invalid phone number format
- `429 Too Many Requests`: Rate limit exceeded

#### Verify Code

**POST** `/realms/{realm}/sms/verification-code`

Verifies an SMS code for the authenticated user.

**Parameters:**

- `phoneNumber` (query, required): Phone number in international format
- `code` (query, required): The verification code received via SMS

**Authentication:** Required (Bearer token)

**Example Request:**

```bash
curl -X POST "http://localhost:8080/realms/wellcare/sms/verification-code?phoneNumber=+1234567890&code=123456" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Example Response:**

```
204 No Content
```

**Response Codes:**

- `204 No Content`: Code verified successfully
- `400 Bad Request`: Invalid code or phone number
- `401 Unauthorized`: Invalid or missing authentication token

### Authentication Code

#### Send Authentication Code

**GET** `/realms/{realm}/sms/authentication-code`

Sends an SMS authentication code for login purposes.

**Parameters:**

- `phoneNumber` (query, required): Phone number in international format
- `kind` (query, optional): Additional context for authentication

**Authentication:** Not required

**Example Request:**

```bash
curl -X GET "http://localhost:8080/realms/wellcare/sms/authentication-code?phoneNumber=+1234567890"
```

**Example Response:**

```json
{
  "expires_in": 300
}
```

**Response Codes:**

- `200 OK`: Code sent successfully
- `400 Bad Request`: Invalid phone number format
- `403 Forbidden`: Phone number not found in system
- `429 Too Many Requests`: Rate limit exceeded

### Registration Code

#### Send Registration Code

**GET** `/realms/{realm}/sms/registration-code`

Sends an SMS registration code for new user registration.

**Parameters:**

- `phoneNumber` (query, required): Phone number in international format
- `kind` (query, optional): Additional context for registration

**Authentication:** Not required

**Example Request:**

```bash
curl -X GET "http://localhost:8080/realms/wellcare/sms/registration-code?phoneNumber=+1234567890"
```

**Example Response:**

```json
{
  "expires_in": 300
}
```

**Response Codes:**

- `200 OK`: Code sent successfully
- `400 Bad Request`: Invalid phone number format
- `409 Conflict`: Phone number already registered
- `429 Too Many Requests`: Rate limit exceeded

### Reset Code

#### Send Password Reset Code

**GET** `/realms/{realm}/sms/reset-code`

Sends an SMS code for password reset.

**Parameters:**

- `phoneNumber` (query, required): Phone number in international format
- `kind` (query, optional): Additional context for password reset

**Authentication:** Not required

**Example Request:**

```bash
curl -X GET "http://localhost:8080/realms/wellcare/sms/reset-code?phoneNumber=+1234567890"
```

**Example Response:**

```json
{
  "expires_in": 300
}
```

**Response Codes:**

- `200 OK`: Code sent successfully
- `400 Bad Request`: Invalid phone number format
- `404 Not Found`: Phone number not found in system
- `429 Too Many Requests`: Rate limit exceeded

### OTP Code

#### Send OTP Code

**GET** `/realms/{realm}/sms/otp-code`

Sends an SMS OTP code for two-factor authentication.

**Parameters:**

- `phoneNumber` (query, required): Phone number in international format
- `kind` (query, optional): Additional context for OTP

**Authentication:** Not required

**Example Request:**

```bash
curl -X GET "http://localhost:8080/realms/wellcare/sms/otp-code?phoneNumber=+1234567890"
```

**Example Response:**

```json
{
  "expires_in": 300
}
```

**Response Codes:**

- `200 OK`: Code sent successfully
- `400 Bad Request`: Invalid phone number format
- `403 Forbidden`: Phone number not found in system
- `429 Too Many Requests`: Rate limit exceeded

## Standard Keycloak Endpoints

The system also supports all standard Keycloak endpoints for authentication and user management.

### Token Endpoint

**POST** `/realms/{realm}/protocol/openid-connect/token`

Standard OAuth2/OIDC token endpoint with phone authentication support.

**Phone Authentication Example:**

```bash
curl -X POST "http://localhost:8080/realms/wellcare/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&client_id=your-client&username=+1234567890&password=123456"
```

**Response:**

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 300,
  "refresh_expires_in": 1800,
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "not-before-policy": 0,
  "session_state": "session-id",
  "scope": "openid email profile"
}
```

### User Management Endpoints

#### Create User

**POST** `/realms/{realm}/users`

Creates a new user with phone verification.

**Example Request:**

```bash
curl -X POST "http://localhost:8080/realms/wellcare/users" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "user123",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "enabled": true,
    "attributes": {
      "phoneNumber": ["+1234567890"],
      "phoneVerified": ["true"]
    }
  }'
```

#### Get User

**GET** `/realms/{realm}/users/{user-id}`

Retrieves user information.

**Example Request:**

```bash
curl -X GET "http://localhost:8080/realms/wellcare/users/user-id" \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

#### Update User

**PUT** `/realms/{realm}/users/{user-id}`

Updates user information.

**Example Request:**

```bash
curl -X PUT "http://localhost:8080/realms/wellcare/users/user-id" \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane",
    "attributes": {
      "phoneNumber": ["+1234567890"]
    }
  }'
```

## Error Responses

All endpoints return consistent error responses:

### Standard Error Format

```json
{
  "error": "error_type",
  "error_description": "Detailed error message"
}
```

### Common Error Types

- `invalid_request`: Missing or invalid parameters
- `invalid_token`: Invalid or expired authentication token
- `insufficient_scope`: Insufficient permissions
- `rate_limit_exceeded`: Too many requests
- `phone_number_invalid`: Invalid phone number format
- `code_expired`: Verification code has expired
- `code_invalid`: Invalid verification code
- `user_not_found`: User not found in system
- `phone_already_registered`: Phone number already registered

## Rate Limiting

The API implements rate limiting to prevent abuse:

- **Per Phone Number**: Maximum codes per hour (configurable)
- **Per IP Address**: Maximum codes per hour (configurable)
- **Response**: 429 Too Many Requests when limits exceeded

## Phone Number Format

All phone numbers must be in international format:

- **Valid**: `+1234567890`, `+84987654321`
- **Invalid**: `1234567890`, `0987654321`

## Security Considerations

1. **Token Expiration**: SMS codes expire after a configurable time (default: 5 minutes)
2. **Rate Limiting**: Prevents brute force attacks
3. **HTTPS Required**: All API calls should use HTTPS in production
4. **Token Validation**: All tokens are validated for authenticity and expiration
5. **Audit Logging**: All authentication attempts are logged for security monitoring
