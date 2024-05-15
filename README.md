# OpenFastLane

OpenFastLane is a digital tool designed for social organizations to streamline the process of checking and managing
people's entitlements.
With OpenFastLane, personalized QR codes can be used to quickly and efficiently check eligibility for certain services,
such as food parcels, vouchers, and more.

This saves both employees and clients valuable time, allowing social organizations to be more effective and
service-oriented while improving the quality of life for disadvantaged people.

![Coverage](.github/badges/jacoco.svg)

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Setup and Prepare your environment](#setup-and-prepare-your-environment)
    - [Environment Variables](#environment-variables)
    - [Config and template data](#config-and-template-data)
        - [config/campaigns.json Schema](#configcampaignsjson-schema)
    - [Setup mongodb environment](#setup-mongodb-environment)
- [Contribution](#contribution)
- [License](#license)
- [Additional Information](#additional-information)

## Features

- **QR Code-Based Entitlement Check**: Use personalized QR codes to quickly validate an individual's entitlement for
  services and goods.
- **Streamlined Management**: Efficiently manage entitlements and reduce administrative overhead.
- **Improved Service Delivery**: Provide better service to clients by reducing wait times and improving the accuracy of
  entitlement checks.
- **Open Source**: OpenFastLane is open source, allowing community contributions and customization to meet specific
  needs.

## Getting Started

Setup Java/kotlin/gradle, Flutter, Docker on your local machine.
To get started with OpenFastLane, follow these steps:

1. **Clone the Repository**

```bash
git clone https://github.com/sensatech/openfastlane.git
```

2. build backend

```bash
cd backend
./gradlew check
./gradlew :server:bootBuildImage
```

2. build and pack frontend

```bash
cd frontend
flutter doctor
flutter pub get
flutter build web --target=lib/main.dart
docker build -t openfastlane-frontend . -f frontend.Dockerfile
```

## Setup and Prepare your environment

The mongoDb docker images and the ofl-backend itself rely on environment variables to be set.

- copy .env-example to .env
- set all necessary secret as ENV Variables in .env, they will be used by all docker containers
- make sure .env is not checked into git, and keep your secrets secret

### Environment Variables

OpenFastLane Server Configuration:

#### OAuth Configuration

- OAUTH_ISSUER_URI: OAuth server's URI for authentication and authorization.
- OAUTH_JWT_ROLE_CLAIM: The JWT claim used to extract user roles.

#### MongoDB Configuration

- MONGO_DATABASE: Name of the MongoDB database used by the server.
- MONGO_URL: MongoDB connection string for connecting to the database.

#### Server Configuration

- WEB_BASE_URL: Base URL for the OpenFastLane web server's admin interface.
- CONFIG_DATA_DIR: Directory for configuration files.
- INSERT_DEMO_DATA: Boolean indicating whether to insert demo data (false by default). DONT do that in production!

other env vars are mostly for mongodb and mongo-express images. Mail sending is not yet implemented.

### Frontend Configuration

To start the the frontent with the right URLs pointing to backend and OAuth server, you need to set the following environment variables:

see frontend/dotenv
```yaml
APP_NAME=OpenFastLane
API_BASE_URL=https://ofl-test.volkshilfe-wien.at/api
OAUTH_REALM=openfastlane-staging
OAUTH_CLIENT_ID=ofl-admin
```

mount YOUR version of that file into the frontend.Dockerfile



### Config and template data

This working state of OpenFastLane does not yet implement a configuration UI.
Therefore, the configuration data is read from a file in the backend.
On startup, the backend reads the configuration data from the file and stores it in the database.

The main data you need to configure is the campaigns, and their contained entitlements causes.
See the config_example folder for an example of the configuration file.

The important files are:

- config_example/campaigns.json (**copy to config/campaigns.json** and adjust it to your needs)

**Attention**

campaigns.json is read on startup and stored in the database.
It can either not exist, which is fine, but when it exists, it must be valid JSON.

**Attention**

You must adjust the docker-compose.yml file to mount the config folder into the backend container:

```yaml
    volumes:
      - ./config:/config
```

Then set CONFIG_DATA_DIR in your .env file to the path where the config folder is mounted in the container.
e.g.:

```dotenv
CONFIG_DATA_DIR=/config
```

#### config/campaigns.json Schema

it is a list of campaigns, each campaign has a list of causes, each cause has a list of criterias.
Every campaign can have a enabled=false flag, to disable it.

**Campaign:**

- 'period' must be one of the following: ONCE, MONTHLY, YEARLY, WEEKLY

```json
{
  "id": "65cb6c1851090750aaaaaaa0",
  "name": "Lebensmittelausgabe",
  "period": "YEARLY",
  "causes": [
    Cause
  ]
}
```

**Cause:**

```json
{
  "id": "65cb6c1851090750aaaaabbb0",
  "campaignId": "65cb6c1851090750aaaaaaa0",
  "name": "MA40",
  "criterias": [
    Criteria
  ]
}
```

**Criteria:**

- type: TEXT, CHECKBOX, OPTIONS, INTEGER, FLOAT, CURRENCY
- **If** 'type' is OPTIONS, 'options' must be an nonempty array of Objects with 'value' and 'label' properties

```json
{
  "id": "65cb6c1851090750aaaaabbc0",
  "name": "Lohnzettel",
  "type": "TEXT",
  "options": [
    Option
  ]
}
```

**Option:**

```json
{
  "key": "MA",
  "label": "MA",
  "order": 0,
  "description": null
}
```

### Setup mongodb environment

After setting your environment variables, you can start the mongodb docker container via docker-compose.

See .env and setup your LOCAL environment accordingly.
As that example file is checked into git, it is not a good idea to put your credentials there.

Therefore, we use "password" as password for the user "ofl" in the following examples,
which matches the .env-example file.

#### Start mongodb

For local **development**:

```bash
docker-compose -f docker-compose-dev.yml up -d
```

For **production** environment with the whole stack (backend, frontend, mongodb, mongo-express)

```bash
docker-compose -f docker-compose.yml up -d
```

#### Create a mongodb user

```bash
mongosh "mongodb://ofl:password@localhost:27027/" --username ofl
```

```python
use openfastlane
db.createUser({
    user: "ofl",
    pwd: "password",
    roles: [
        {role: "readWrite", db: "openfastlane"},
    ]
})
```

#### Test that the connection works for your Database with the new user

```bash
mongosh "mongodb://ofl:password@localhost:27027/openfastlane" --username ofl
```

Must succeed! Otherwise database and user are not set up correctly.

# Contribution

Thank you for your interest in contributing to OpenFastLane! We welcome contributions from everyone, whether it's through code, documentation, or suggestions for improvement. This guide outlines how you can contribute and what to consider when doing so.

## Areas of Focus
While we appreciate contributions across the board, we currently focus on improving the configuration UI. If you have experience in front-end development or UX/UI design, your insights will be especially valuable.

## How to Contribute
There are several ways you can contribute to OpenFastLane:

1. **Report Issues**: If you find a bug or have suggestions for new features or improvements, please start a ticket in our [GitHub Issues](https://github.com/sensatech/openfastlane/issues). Describe the issue or suggestion in detail and provide any relevant context or code snippets.

2. **Propose Changes**: If you would like to make code changes, please create a ticket to discuss the proposed changes before submitting a pull request. This helps us avoid duplicate work and ensures that your contribution aligns with the project's goals.

3. **Submit Pull Requests**:
  - Fork the repository and create a new branch for your changes.
  - Make your changes in the new branch, ensuring they adhere to the project's coding standards and guidelines.
  - Include any necessary tests to validate your changes.
  - Open a pull request from your branch to the main repository.
  - Reference the relevant issue in your pull request description.
  - Wait for feedback from the maintainers and be open to revisions.

## Guidelines for Code Contributions
When contributing code, please follow these guidelines:

- **Coding Style**: Adhere to the project's coding standards. 
If you're unsure, refer to the existing codebase for guidance.
For kotlin, run `./gradlew ktlintCheck` to check for style violations.
For flutter, run `flutter analyze` to check for style violations.
- **Testing**: Ensure your code is properly tested. Add or update tests as needed to cover your changes.
- **Documentation**: Update documentation if your changes affect functionality or configuration. This includes updating any relevant Readme sections, setup guides, or user manuals.
- **Commit Messages**: Write clear, descriptive commit messages that explain the purpose of the changes.


# License

Copyright 2024 - Sensatech GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

[See LICENSE](LICENSE)

# Additional Information

This project is funded by the netidee initiative of the Internet Foundation Austria (IPA) in year 2023/2024.

* Official netidee page: [https://www.netidee.at/openfastlane](https://www.netidee.at/openfastlane)
* OpenFastLane for your Organisation: https://www.sensatech.at/openfastlane-ausprobieren/ (DE)
* Get in touch with us: https://www.sensatech.at/en/projects/openfastlane-en/ (EN)