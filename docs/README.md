# Documentation

This directory contains comprehensive documentation for the Keycloak Wellcare project, including database schema, API endpoints, system workflows, and state machines.

## 📋 Documentation Files

### [`database.md`](./database.md)

Database schema documentation using **DBML** (Database Markup Language). Contains:

- Table definitions with field names and types
- Field-level attributes (primary keys, constraints, notes)
- Foreign key relationships
- Indexes and optimization hints

### [`sequence.md`](./sequence.md)

System workflows and interactions between services using **Mermaid.js** sequence diagrams. Documents:

- HTTP API interactions
- SMS provider integrations
- Authentication flows
- Message passing between components

### [`api.md`](./api.md)

Complete API reference documentation including:

- Available REST endpoints
- HTTP methods and paths
- Request/response schemas
- Authentication requirements
- Example requests and responses

### [`state-machine.md`](./state-machine.md)

State machine documentation using **Mermaid.js** state diagrams. Covers:

- Authentication flow states
- SMS verification workflows
- User registration processes
- Password reset flows
- State transitions and triggers

## 💡 Diagram Rendering

Some diagrams use [Mermaid.js](https://mermaid.js.org/) and [DBML](https://dbdiagram.io/docs). Open these files in **Cursor**, **Obsidian**, or **VS Code** with the appropriate plugins to render them.

### Recommended Extensions:

- **VS Code**: Mermaid Preview, DBML Preview
- **Cursor**: Built-in Mermaid support
- **Obsidian**: Built-in Mermaid support

### Online Viewers:

- **Mermaid**: [Mermaid Live Editor](https://mermaid.live/)
- **DBML**: [dbdiagram.io](https://dbdiagram.io/)

## 🔄 Documentation Updates

This documentation is automatically generated and should be updated when:

- Database schema changes
- New API endpoints are added
- Authentication flows are modified
- SMS provider integrations are updated

## 📚 Related Resources

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Keycloak Phone Provider](https://github.com/cooperlyt/keycloak-phone-provider)
- [Wellcare Platform Documentation](https://wellcare.vn/docs)
