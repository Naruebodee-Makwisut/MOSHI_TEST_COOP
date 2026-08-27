# API Testing Fundamentals

> QA Portfolio topic: API Testing
> This document covers the foundational knowledge a QA should understand before testing real-world APIs.

---

## Table of Contents

1. [What is an API](#1-what-is-an-api)
2. [What is API Testing and Why It Matters](#2-what-is-api-testing-and-why-it-matters)
3. [Types of APIs](#3-types-of-apis)
4. [Request / Response Structure](#4-request--response-structure)
5. [HTTP Methods](#5-http-methods)
6. [HTTP Status Codes](#6-http-status-codes)
7. [Types of API Testing](#7-types-of-api-testing)
8. [What QA Should Check When Testing an API](#8-what-qa-should-check-when-testing-an-api)
9. [Common API Testing Tools](#9-common-api-testing-tools)
10. [Best Practices](#10-best-practices)
11. [Sample Test Cases](#11-sample-test-cases)
12. [Summary](#12-summary)

---

## 1. What is an API

An **API (Application Programming Interface)** is a set of rules and protocols that defines how two software systems communicate with each other. It acts as a "middleman" that allows a client (such as a website or mobile app) to request or send data to a server, without needing to know the internal implementation details of either side.

**A simple analogy:**
Think of an API like a waiter in a restaurant — the customer (client) orders food through the waiter (API) instead of walking into the kitchen (server) directly. The waiter takes the order, passes it to the kitchen, and brings the finished dish back to the customer.

---

## 2. What is API Testing and Why It Matters

**API Testing** is the process of testing an API directly (without going through the UI) to verify that:

- The system returns the correct response as expected
- The business logic behaves correctly
- The system handles errors and edge cases appropriately
- Performance, security, and reliability meet acceptable standards

### Why API Testing Matters

| Reason | Details |
|---|---|
| **Faster than UI Testing** | No need to wait for screen rendering; tests run quickly and are easy to automate |
| **Catches bugs earlier** | Can be tested as soon as the backend is ready, even before the frontend is complete |
| **Better coverage** | Business logic, edge cases, and error handling can be tested more thoroughly than by clicking through screens |
| **More stable** | Not affected by UI changes such as layout or CSS selector updates |
| **Automation/CI-CD friendly** | Easy to write automated tests and integrate into a pipeline |

---

## 3. Types of APIs

| Type | Key Characteristics | Example Use Cases |
|---|---|---|
| **REST (Representational State Transfer)** | Uses HTTP methods, primarily transfers data via JSON, stateless | Most modern APIs, e.g. e-commerce, banking |
| **SOAP (Simple Object Access Protocol)** | Uses XML, follows strict standards (WSDL), emphasizes high security | Enterprise/legacy systems, e.g. finance, insurance |
| **GraphQL** | Client specifies exactly which fields it needs, reduces over-fetching | Facebook, GitHub API |
| **gRPC** | Uses Protocol Buffers, high performance, ideal for microservices | Internal systems requiring high performance |

> 📌 Most of the testing in this portfolio focuses on **REST APIs**, as they are the most common type used in the industry today.

---

## 4. Request / Response Structure

### 4.1 Request Structure

```
Method:  POST
URL:     https://api.example.com/v1/users
Headers: 
  Content-Type: application/json
  Authorization: Bearer <token>
Body (Payload):
{
  "name": "Somchai",
  "email": "somchai@example.com"
}
```

- **Method** – the type of action to be performed (GET, POST, PUT, DELETE, ...)
- **URL / Endpoint** – the location of the resource being accessed
- **Headers** – metadata such as Content-Type or Authorization token
- **Body / Payload** – the data being sent (mainly used with POST, PUT, PATCH)
- **Query Parameters** – values attached to the URL, e.g. `?page=1&limit=10`

### 4.2 Response Structure

```
Status Code: 201 Created
Headers:
  Content-Type: application/json
Body:
{
  "id": 1024,
  "name": "Somchai",
  "email": "somchai@example.com",
  "createdAt": "2026-08-13T10:00:00Z"
}
```

- **Status Code** – indicates the result of the request (success/failure)
- **Headers** – metadata about the response
- **Body** – the data returned by the server

---

## 5. HTTP Methods

| Method | Used For | Idempotent? | Has Body? |
|---|---|---|---|
| **GET** | Retrieve data (Read) | ✅ Yes | Generally no |
| **POST** | Create new data (Create) | ❌ No | Yes |
| **PUT** | Replace an entire resource (Replace) | ✅ Yes | Yes |
| **PATCH** | Update part of a resource (Update) | ❌ No (generally) | Yes |
| **DELETE** | Delete a resource | ✅ Yes | Generally no |

> **Idempotent** means that sending the same request multiple times produces the same final result, without additional side effects.

---

## 6. HTTP Status Codes

### 6.1 Status Code Groups

| Group | Meaning |
|---|---|
| **1xx – Informational** | Request received, processing continues |
| **2xx – Success** | Request succeeded |
| **3xx – Redirection** | Further action is needed to complete the request |
| **4xx – Client Error** | The client sent an invalid request |
| **5xx – Server Error** | An error occurred on the server side |

### 6.2 Commonly Used Status Codes

| Code | Meaning | When It Occurs |
|---|---|---|
| `200 OK` | Success | GET/PUT/PATCH succeeded |
| `201 Created` | Resource created successfully | POST created a new resource |
| `204 No Content` | Success, no content returned | DELETE succeeded |
| `400 Bad Request` | Malformed request | Invalid body/parameter sent |
| `401 Unauthorized` | Not authenticated | Missing or expired token |
| `403 Forbidden` | No permission to access | Valid token but insufficient permissions |
| `404 Not Found` | Resource not found | Invalid endpoint or ID |
| `409 Conflict` | Data conflict | Duplicate data being created |
| `422 Unprocessable Entity` | Well-formed request but validation failed | Data doesn't meet business rules |
| `429 Too Many Requests` | Rate limit exceeded | Requests sent too frequently |
| `500 Internal Server Error` | Server-side issue | Backend bug |
| `503 Service Unavailable` | Server not ready to handle requests | Server down/under maintenance |

---

## 7. Types of API Testing

| Type | Goal |
|---|---|
| **Functional Testing** | Verify the API behaves according to requirements (correct input → output) |
| **Validation Testing** | Verify the response matches the expected schema/data type |
| **Negative Testing** | Test with invalid input to check how the system handles errors |
| **Integration Testing** | Test how multiple APIs/services work together |
| **Load / Performance Testing** | Test the system's capacity to handle load and response time |
| **Security Testing** | Check for vulnerabilities such as authentication and authorization flaws, injection attacks |
| **Contract Testing** | Verify the API still matches the contract expected by consumers (e.g. Pact) |
| **Regression Testing** | Re-test after deployment to ensure existing features still work |

---

## 8. What QA Should Check When Testing an API

1. **Status Code** is correct for the given scenario
2. **Response Body** matches expectations (all fields present, correct values, correct data types)
3. **Response Time** falls within an acceptable range
4. **Response Headers** are correct (e.g. Content-Type)
5. **Error Messages** are clear and do not leak sensitive information (e.g. stack traces)
6. **Authentication / Authorization** works correctly (access denied without proper permissions)
7. **Boundary Values** such as negative numbers, empty values, or values exceeding length limits
8. **Idempotency** of methods that are expected to be idempotent
9. **Data Consistency** across related requests, e.g. data created should match data retrieved afterward
10. **Pagination / Filtering / Sorting** (if applicable) works correctly

---

## 9. Common API Testing Tools

| Tool | Category | Key Strengths |
|---|---|---|
| **Postman** | Manual + Automation | Easy to use, great for getting started, includes Collection Runner |
| **REST Assured** | Automation (Java) | Code-based automated testing, CI/CD friendly |
| **Swagger / OpenAPI** | Documentation | View/test APIs based on defined specs |
| **k6 / JMeter** | Performance Testing | Load and stress testing |
| **Newman** | CLI Runner for Postman | Run Postman collections via command line/CI pipeline |
| **Pytest + Requests** | Automation (Python) | Write API tests in Python, simple and flexible |

---

## 10. Best Practices

- ✅ Write test cases covering both **positive** and **negative** scenarios
- ✅ Validate the **response schema**, not just the status code
- ✅ Separate test data from test scripts for easier maintenance
- ✅ Use **environment variables** for URLs/tokens instead of hardcoding
- ✅ Perform **test data cleanup** after testing to avoid affecting other tests
- ✅ Check **basic security**, e.g. requests should not succeed without a valid token
- ✅ Automate frequently repeated tests and integrate them into a CI/CD pipeline
- ✅ Write tests that are **independent** and do not rely on the execution order of other tests

---

## 11. Sample Test Cases

**Sample Endpoint:** `POST /api/v1/users`

| Test Case ID | Description | Input | Expected Result |
|---|---|---|---|
| TC-01 | Successfully create a user with valid data | Complete, valid body | `201 Created`, response includes `id` and matches submitted data |
| TC-02 | Create a user without a required field | Missing `email` | `400 Bad Request`, error message specifies the missing field |
| TC-03 | Create a user with an email that already exists | Duplicate `email` | `409 Conflict` |
| TC-04 | Create a user without an Authorization token | No Authorization header sent | `401 Unauthorized` |
| TC-05 | Create a user with an invalid email format | `email: "not-an-email"` | `422 Unprocessable Entity` |
| TC-06 | Verify response time | Normal request | Response time < 1 second |

---

## 12. Summary

API testing is a fundamental skill for modern QA professionals, as it allows issues to be detected faster, deeper, and more efficiently than UI testing alone. Understanding the basics of HTTP structure, status codes, and different types of API testing forms the foundation for more advanced topics later in this portfolio, such as **API Automation Testing**, **Contract Testing**, and **Performance Testing**.

---

*Recommended next topic: [02-Business-Central-API](https://github.com/Printdonut4444/QA-Portfolio/tree/main/02-Skills/2.2-API%20Testing/02-Business-Central-API)*
