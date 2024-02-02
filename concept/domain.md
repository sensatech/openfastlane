# Domain model

- Kampagne: Campaign
- Ansuchgrund: Entitlement Cause
- Anspruchsberechtigung: Entitlement
- Anspruchsberechtigte: (Entitled) Person
- Bezug / Inanspruchnahme: Consumption / utilization
- Bezugsberechtigung (BB): Consumption Permission

```mermaid

---
title: Domain model
---
classDiagram

    Campaign o-- EntitlementCause
    EntitlementCause *-- EntitlementCriteria
   
    Entitlement --* Person
    Entitlement --* EntitlementCause
    Entitlement *-- EntitlementValue
    EntitlementValue ..|> EntitlementCriteria

    Consumption --> Entitlement
    Consumption --> EntitlementCause
    Consumption --> Campaign
    Consumption --> Person

    class Campaign{
        +String id
        +String name
        +Period period
    }

    class EntitlementCause{
        +String id
        +String campaignId
        +String name
        +List<EntitlementCriteria> criterias
    }

    class EntitlementCriteria{
        +String name
        +EntitlementCriteriaType type
        +String? reportKey
    }

    class EntitlementValue{
        +String criteriaId
        +EntitlementCriteriaType type
        +ANY value
    }
    
    class Person{
        +String firstName
        +String lastName
        +String gender
        +Address address
        +String comment
        +Date registeredAt
    }
    class Entitlement{
        +Person person
        +List<EntitlementValue> values
    }

    class Consumption{
        +Date createdAt
        +Date updatedAt
        +Date validUntil
    }


     class Period {
        <<enumeration>>
        ONCE
        MONTHLY
        YEARLY
        WEEKLY
    }

    class EntitlementCriteriaType {
        <<enumeration>>
        TEXT
        CHECKBOX
        OPTIONS
        INTEGER
        FLOAT
    }

```
