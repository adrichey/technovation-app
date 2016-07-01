# Technovation Challenge Platform

## Setup

```
git clone git@github.com:Iridescent-CM/technovation-app.git
cd technovation-app
bundle install
./bin/setup
```

## Tests

TechnovationApp uses Minitest

```
$ rake
```

## User Accounts

### Distinguished by profile types (judge, student, mentor, coach...)

Developers should interact with user accounts by their respectively named child classes:

```ruby
AdminAccount.find # ...
CoachAccount.find # ...
JudgeAccount.create # ...
MentorAccount.where # ...
StudentAccount # ...
```

These models return child instances of `Account` which hold their proper `{Name}Profile`.

Do not directly access the `{Name}Profile` and `Account` models, they are deep implementation details.

### {ProfileName}Account

* Behavior specific to its associated profile type
* Validates its associated profile type

### Account

* **Do not access directly**
* Authentication attributes (email, password, auth_token)
* Basic attributes shared by all accounts (name, address, date of birth, etc)
* Validations for these attributes

### {Name}Profile

* **Do not access directly**
* Attributes and validations specific to each type of profile
  * (e.g., `StudentProfile` has `#parent_guardian_email` but other `{Name}Profile`s do not)
* Authorization in controllers is inferred by the association of these profiles to the `Account` with the cookie'd auth_token

## Rails.root/app/technovation/

### FindAuthenticationRole

* Use this module as the API for authenticating based on auth_token in cookies

```ruby
FindAuthenticationRole.current(:student, cookies)
```

### SearchMentors

* Call with a `SearchFilter` instance
* Filter options:
  * :expertise_ids
    * can be a single ID, or a collection of IDs

```ruby
search_filter = SearchFilter.new({ expertise_ids: 1 })
SearchMentors.(search_filter)

search_filter = SearchFilter.new({ expertise_ids: [1, 2] })
SearchMentors.(search_filter)

search_filter = SearchFilter.new({ expertise_ids: ["1", "2"] })
SearchMentors.(search_filter)
```

### CreateScoringRubric

* Used in tests and seeds, ignore for now

## Controllers

Wherever the helper `current_<profile_type>` is available, it returns an instance `<profile_type>Account`.
