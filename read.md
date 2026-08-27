# Business Central API Development

## Overview

This section demonstrates how a custom REST API is developed in **Microsoft Dynamics 365 Business Central** using AL.

A custom **Customer API** is created from a Business Central table and exposed through an API Page.

The implementation consists of two main components:

```text
Customer API Table
        │
        │ SourceTable
        ▼
Customer API Page
        │
        ▼
REST API Endpoint
```

---

## Objective

The purpose of this implementation is to demonstrate an understanding of how Business Central data can be exposed through a custom REST API.

The API is designed to support basic customer management operations such as:

* Retrieve customers
* Create customers
* Update customers
* Delete customers

The resulting API is then used in the API Testing section of this portfolio.

---

# 1. Customer API Table

The `Customer API` table is the data source for the REST API.

It stores customer master data such as customer identification, contact information, status, and financial information.

### Main Fields

| Field              | Type      | Purpose                       |
| ------------------ | --------- | ----------------------------- |
| No.                | Code[20]  | Unique customer identifier    |
| Name               | Text[100] | Customer name                 |
| Email              | Text[100] | Customer email                |
| Phone No.          | Text[30]  | Customer phone number         |
| Address            | Text[250] | Customer address              |
| City               | Text[50]  | Customer city                 |
| Country            | Code[10]  | Customer country              |
| Postal Code        | Code[20]  | Postal code                   |
| Customer Type      | Enum      | Individual / Company          |
| Status             | Enum      | Active / Inactive / Blocked   |
| Registration Date  | Date      | Customer registration date    |
| Last Modified Date | DateTime  | Last modification timestamp   |
| Credit Limit       | Decimal   | Customer credit limit         |
| Currency Code      | Code[10]  | Currency used by the customer |
| Marketing Consent  | Boolean   | Marketing consent status      |

### Primary Key

The customer number is used as the primary key:

```al
key(PK; "No.")
{
    Clustered = true;
}
```

This ensures that each customer record has a unique identifier.

### Source Code 
**[CustomerAPI.Table.al](https://github.com/Printdonut4444/QA-Portfolio/blob/main/02-Skills/2.2-API%20Testing/02-Business-Central-API/Table/CustomerAPI.Table.al)**
```text
Table/
└── CustomerAPI.Table.al
```

---

# 2. API Page

The `QA Customer API` page exposes the `Customer API` table as a REST API.

```al
page 50100 "QA Customer API"
{
    PageType = API;

    APIPublisher = 'donut';
    APIGroup = 'qa';
    APIVersion = 'v1.0';

    EntityName = 'customer';
    EntitySetName = 'customers';

    SourceTable = "Customer API";

    DelayedInsert = true;

    ...
}
```

### API Configuration

| Property      | Value          | Purpose                             |
| ------------- | -------------- | ----------------------------------- |
| PageType      | `API`          | Defines the page as an API endpoint |
| APIPublisher  | `donut`        | Identifies the API publisher        |
| APIGroup      | `qa`           | Groups the API                      |
| APIVersion    | `v1.0`         | Defines the API version             |
| EntityName    | `customer`     | Defines the individual resource     |
| EntitySetName | `customers`    | Defines the collection resource     |
| SourceTable   | `Customer API` | Connects the API to the data table  |

### Source Code
**[CustomerAPI.Page.al](https://github.com/Printdonut4444/QA-Portfolio/blob/main/02-Skills/2.2-API%20Testing/02-Business-Central-API/API-Page/CustomerAPI.Page.al)**
```text
API-Page/
└── CustomerAPI.Page.al
```

---

# 3. API Endpoint

Based on the API Page configuration, Business Central exposes the customer entity through the standard API endpoint structure:

```text
/api/{publisher}/{group}/{version}/companies({companyId})/{entitySet}
```

For this project:

```text
/api/donut/qa/v1.0/companies({companyId})/customers
```

### Endpoint Breakdown

```text
/api
  │
  ├── donut
  │     └── API Publisher
  │
  ├── qa
  │     └── API Group
  │
  ├── v1.0
  │     └── API Version
  │
  ├── companies({companyId})
  │     └── Business Central Company
  │
  └── customers
        └── Entity Set
```

---

# 4. Data Flow

The relationship between the Business Central objects and the REST API is:

```text
┌──────────────────────────┐
│   Customer API Table     │
│                          │
│  Customer Data           │
└────────────┬─────────────┘
             │
             │ SourceTable
             ▼
┌──────────────────────────┐
│   QA Customer API        │
│                          │
│   PageType = API         │
└────────────┬─────────────┘
             │
             │ REST API
             ▼
┌──────────────────────────┐
│      REST Endpoint       │
│                          │
│   /customers             │
└────────────┬─────────────┘
             │
             ▼
      API Client / Tool
```

---

# 5. CRUD Operations

The API supports the standard CRUD operations provided by the Business Central API framework.

| HTTP Method | Operation | Description                 |
| ----------- | --------- | --------------------------- |
| GET         | Read      | Retrieve customer data      |
| POST        | Create    | Create a new customer       |
| PATCH       | Update    | Modify an existing customer |
| DELETE      | Delete    | Remove a customer           |

Example:

```text
GET     /customers
GET     /customers({id})
POST    /customers
PATCH   /customers({id})
DELETE  /customers({id})
```

---

# 6. Example: Creating a Customer

A new customer can be created by sending a `POST` request to the API.

### Request

```http
POST /customers
Content-Type: application/json
```

```json
{
  "no": "C00001",
  "name": "Donut Technology Co., Ltd.",
  "email": "contact@donut-tech.com",
  "phoneNo": "0812345678",
  "city": "Bangkok",
  "country": "TH",
  "postalCode": "10110",
  "customerType": "Company",
  "status": "Active",
  "creditLimit": 100000,
  "currencyCode": "THB",
  "marketingConsent": true
}
```

The request is processed by the Business Central API and a new record is created in the `Customer API` table.

```text
POST Request
     │
     ▼
Customer API
     │
     ▼
Customer API Table
     │
     ▼
C00001 created
```

The newly created customer can then be viewed in Business Central.

---

# 7. Example: Updating a Customer

An existing customer can be updated using `PATCH`.

```http
PATCH /customers({id})
Content-Type: application/json
```

```json
{
  "name": "Donut Technology Updated",
  "phoneNo": "0899999999"
}
```

Only the specified fields are updated while other customer information remains unchanged.

---

# 8. Business Central Result

The data created or modified through the REST API is stored in the `Customer API` table.

For example:

```text
Customer API

No.       Name                         Email
----------------------------------------------------------------
C00001    Donut Technology Co., Ltd.   contact@donut-tech.com
C00002    John Smith                   john@example.com
```

This allows the API request and the resulting Business Central data to be compared during API testing.

---

# 9. Development Structure

```text
01-Business-Central-API
│
├── README.md
│
├── Table
│   └── CustomerAPI.Table.al
│
└── API-Page
    └── CustomerAPI.Page.al
```

---

## Key Concepts Demonstrated

This implementation demonstrates practical understanding of:

* Business Central AL development
* Custom Tables
* Primary Keys
* API Pages
* `SourceTable`
* API Publisher
* API Group
* API Versioning
* Entity Name / Entity Set Name
* REST API architecture
* JSON request bodies
* CRUD operations
* Business Central data flow

---

## Next Step

The custom API developed in this section is used as the system under test in:

[03-API-Cases](https://github.com/Printdonut4444/QA-Portfolio/tree/main/02-Skills/2.2-API%20Testing/04-Test-Cases)

The API is tested using REST API requests and the resulting data is verified against the records stored in Business Central.
