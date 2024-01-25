# Class diagram

    Kampagne: Campaign
    Ansuchgrund: Entitlement Cause
    Anspruchsberechtigung: Entitlement
    Anspruchsberechtigte: Entitled Person
    Bezug / Inanspruchnahme: Consumption / utilization
    Bezugsberechtigung (BB): Consumption Permission

```mermaid

---
title: Animal example
---
classDiagram

    class Period{
        <<enumeration>>
        ONCE
        MONTHLY
        YEARLY
        WEEKLY
    }

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

    Campaign o-- EntitlementCause

    class EntitlementCriteriaType {
        <<enumeration>>
        TEXT
        CHECKBOX
        OPTIONS
        INTEGER
        FLOAT
    }

    class EntitlementCriteria{
        +String name
        +EntitlementCriteriaType type
        +String? reportKey
    }

    EntitlementCause *-- EntitlementCriteria

     class Person{ }
     class Entitlement{ }
     class Consumption{ }


```
