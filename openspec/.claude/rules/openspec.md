---
paths: openspec/specs/**/*.md
---

# OpenSpec Specifications

Process Flow をRequirementレベルに埋め込む：

```markdown
### Requirement: [Name]
[Description] (**MUST** / **SHOULD** / **MAY**)

#### Process Flow
```mermaid
sequenceDiagram
    User->>Frontend: Action
    Frontend->>Backend: API
    Backend->>DB: Query
```
```

#### Scenario: [Name]
- **WHEN** ...
- **THEN** ...
```
```
