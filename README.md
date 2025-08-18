# Keycloak Wellcare

A customized Keycloak authentication server with phone/SMS authentication capabilities, specifically tailored for the Wellcare healthcare platform.

## 🎯 Project Overview

This repository contains a customized Keycloak instance that extends the standard Keycloak authentication server with:

- **Phone/SMS Authentication**: Multi-provider SMS service integration for OTP and authentication
- **Custom Wellcare Theme**: Branded login and account management interfaces
- **Multiple SMS Providers**: Support for various SMS services (Wellcare, Twilio, AWS SNS, Aliyun, etc.)
- **Healthcare-Focused Features**: Authentication flows optimized for healthcare applications

## 🛠 Tech Stack

- **Base**: Keycloak 26.1.0 (Quarkus-based)
- **Container**: Docker with Bitnami Keycloak image
- **Database**: PostgreSQL
- **SMS Services**: Multiple provider support (Wellcare, Twilio, AWS SNS, Aliyun, Tencent, etc.)
- **Build System**: Maven (for phone provider modules)
- **CI/CD**: Drone CI for automated builds and deployments
- **Language**: Java 17

## 📁 Folder Structure

```
├── themes/wellcare/           # Custom Keycloak theme
│   ├── login/                # Login page customization
│   └── account/              # Account management customization
├── providers/                # Keycloak provider JARs
│   ├── wellcare-theme.jar    # Theme provider
│   ├── keycloak-bcrypt.jar   # Password hashing
│   └── apple-identity-provider.jar # Apple OAuth
├── keycloak-phone-provider/  # Phone authentication extension
│   ├── keycloak-phone-provider/           # Core phone provider
│   ├── keycloak-sms-provider-wellcare/    # Wellcare SMS service
│   ├── keycloak-sms-provider-twilio/      # Twilio SMS service
│   └── [other SMS providers]/             # Additional SMS services
├── docker-compose.yaml       # Local development setup
├── Dockerfile               # Production container build
└── .drone.yml              # CI/CD pipeline configuration
```

## 🚀 Installation & Setup

### Prerequisites

- Docker and Docker Compose
- Java 17 (for development)
- Maven (for building phone provider)

### Quick Start

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd keycloak
   ```

2. **Start with Docker Compose**:

   ```bash
   docker-compose up -d
   ```

3. **Access Keycloak**:
   - URL: http://localhost:8080
   - Admin Username: `adminuser`
   - Admin Password: `admin123`

### Production Deployment

1. **Build the custom image**:

   ```bash
   docker build -t keycloak:wellcare .
   ```

2. **Configure environment variables**:

   ```bash
   export KEYCLOAK_ADMIN_USER=your_admin_user
   export KEYCLOAK_ADMIN_PASSWORD=your_secure_password
   export DB_VENDOR=POSTGRES
   export DB_ADDR=your_db_host
   export DB_DATABASE=keycloak
   export DB_USER=keycloak
   export DB_PASSWORD=your_db_password
   ```

3. **Start the container**:
   ```bash
   docker run -d \
     --name keycloak-wellcare \
     -p 8080:8080 \
     -e KEYCLOAK_ADMIN_USER=$KEYCLOAK_ADMIN_USER \
     -e KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD \
     -e DB_VENDOR=$DB_VENDOR \
     -e DB_ADDR=$DB_ADDR \
     -e DB_DATABASE=$DB_DATABASE \
     -e DB_USER=$DB_USER \
     -e DB_PASSWORD=$DB_PASSWORD \
     keycloak:wellcare
   ```

## 🔑 Key Features

### Phone Authentication

- **SMS OTP**: One-time password via SMS
- **Phone Login**: Direct login using phone number
- **Phone Registration**: User registration with phone verification
- **Password Reset**: Reset password via SMS
- **2FA Support**: SMS as second factor authentication

### SMS Provider Support

- **Wellcare SMS**: Custom SMS service for healthcare platform
- **Twilio**: International SMS service
- **AWS SNS**: Amazon Simple Notification Service
- **Aliyun**: Alibaba Cloud SMS service
- **Tencent**: Tencent Cloud SMS service
- **Multiple Others**: BulkSMS, TotalVoice, Cloopen, YunTongXun

### Custom Theme

- **Wellcare Branding**: Healthcare-focused UI design
- **Multi-language**: Vietnamese and English support
- **Responsive Design**: Mobile-friendly interface
- **Accessibility**: WCAG compliant design

## 📡 API Usage

### Send SMS Code

```bash
curl -X GET "http://localhost:8080/realms/your-realm/sms/verification-code?phoneNumber=+1234567890" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Verify SMS Code

```bash
curl -X POST "http://localhost:8080/realms/your-realm/sms/verification-code" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber": "+1234567890", "code": "123456"}'
```

### Phone Authentication

```bash
curl -X POST "http://localhost:8080/realms/your-realm/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&client_id=your-client&username=+1234567890&password=123456"
```

## 🔧 Configuration

### SMS Provider Configuration

Configure your preferred SMS provider in Keycloak:

```bash
# For Wellcare SMS
--spi-phone-default-service=wellcare \
--spi-message-sender-service-wellcare-username=your_username \
--spi-message-sender-service-wellcare-password=your_password \
--spi-message-sender-service-wellcare-url=https://wellcare.vn/v1/messages

# For Twilio
--spi-phone-default-service=twilio \
--spi-message-sender-service-twilio-account-sid=your_account_sid \
--spi-message-sender-service-twilio-auth-token=your_auth_token
```

### Theme Configuration

Enable the Wellcare theme in Keycloak Admin Console:

1. Go to Realm Settings → Themes
2. Set Login Theme to "wellcare"
3. Set Account Theme to "wellcare"


## 📝 License
Internal use only. Not licensed for external distribution or third-party use.
