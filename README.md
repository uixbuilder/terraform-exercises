# Solved Terraform Exercises

This directory contains my solutions to Terraform exercises as part of my learning journey.

## Structure

Each exercise is placed in its own folder, for example:

```
solved-exercises/
├── .env
├── .gitignore
├── exercise01/
│   └── <files>
├── exercise02/
│   └── vpc.tf
...
```

- `.env` holds environment variables and is excluded from this repo (e.g., AWS credentials, region).
- `.gitignore` excludes sensitive files and Terraform state.
- Each `exerciseXX` folder contains its own Terraform configuration.

### logs-collecting-with-fluentd
This sample demonstrates using Docker Compose with a Bash script logger and Fluentd to collect and filter logs.

The directory structure is as follows:

```
logs-collecting-with-fluentd/
├── docker-compose.yaml          # orchestrates services (file-logger and Fluentd)
├── file-logger/
│   └── app.sh                   # Bash script that generates random log events
├── file-logger-logs/
│   └── app.log                  # log file written by the file-logger container
├── fluentd-configurations/
│   └── fluent.conf              # Fluentd configuration for filtering logs
└── fluentd-filtered-logs/
    └── errors                   # folder where filtered ERROR logs are stored (with buffer and meta files)
```

The sample works as follows:

- The `file-logger` container runs a Bash script (`app.sh`) that writes random INFO, DEBUG, or ERROR events in JSON format to `file-logger-logs/app.log`.
- Each log event looks like this:

  ```json
  {"timestamp":"2025-09-22T11:38:54Z","level":"INFO","id":"398e6587-808f-4146-8883-495112d68bb8","message":"Heartbeat OK"}
  ```

- A Fluentd container tails this log file, parses each line as JSON, and filters records by the `level` field.
- Only `ERROR` events are written to `fluentd-filtered-logs/errors`.
- The core part of the Fluentd configuration (`fluent.conf`) that performs the error filtering is:

  ```conf
  <filter app.errors-log>
    @type grep
    <regexp>
      key level
      pattern ^ERROR$
    </regexp>
  </filter>
  ```

#### Usage

1. Start the environment with:
   ```bash
   docker compose up -d
   ```
2. Watch log files under `file-logger-logs/app.log`.
3. View filtered logs under `fluentd-filtered-logs/errors`.

#### Notes

- Only `ERROR` events are collected by Fluentd into the filtered logs.
- This setup is for demonstration purposes and can be extended for more complex log filtering and processing.

### exercise02
Provisions a VPC (`10.0.0.0/16`) with one public subnet, one private subnet, an Internet Gateway, a public route table, and the correct association for Internet access.
```mermaid
graph TD
    VPC["VPC 10.0.0.0/16"]
    PublicSubnet["Public Subnet 10.0.0.0/24"]
    PrivateSubnet["Private Subnet 10.0.1.0/24"]
    IGW["Internet Gateway"]
    RTB["Public Route Table"]

    VPC --> PublicSubnet
    VPC --> PrivateSubnet
    VPC --> IGW
    PublicSubnet --> RTB
    RTB --> IGW
```

#### Usage

1. Navigate to the exercise folder you want to run:
   ```bash
   cd exercise02
   ```

2. Initialize Terraform (downloads providers and modules):
   ```bash
   terraform init
   ```

3. Plan the infrastructure changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration to create resources:
   ```bash
   terraform apply
   ```

#### Notes

- Before running Terraform, load environment variables from `.env` (from inside an exercise folder):
  ```bash
  set -a
  source ../.env
  set +a
  ```

- Make sure you have AWS CLI configured and working:
  ```bash
  aws sts get-caller-identity
  ```