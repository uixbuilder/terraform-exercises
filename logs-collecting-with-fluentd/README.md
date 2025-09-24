# Logs Collecting with Fluentd

This example demonstrates using **Fluentd with Kubernetes-style annotations** for flexible, dynamic log filtering.

## Directory Structure

```
logs-collecting-with-fluentd/
├── docker-compose.yaml          # Orchestrates services (file-logger-a, file-logger-b, and Fluentd)
├── file-logger/
│   └── app.sh                   # Bash script that generates random log events with namespace & annotations
├── file-logger-logs/
│   ├── app-a.log                # Log file written by the file-logger-a container
│   └── app-b.log                # Log file written by the file-logger-b container
├── fluentd-configurations/
│   └── fluent.conf              # Fluentd configuration with annotation-driven filtering pipeline
└── fluentd-filtered-logs/
    └── merged.log               # Merged filtered logs from both loggers (with buffer and meta files)
```

## How It Works

- `file-logger-a` and `file-logger-b` containers run `app.sh`, which generates random **INFO/DEBUG/ERROR events** in JSON format.
- Each log entry includes:
  - A Kubernetes `namespace_name`
  - An optional `annotations` block, constructed from environment variables with the prefix **`K8S_ANNOTATIONS_`**.

### Example Annotations

Defined in [`docker-compose.yaml`](docker-compose.yaml):

```yaml
K8S_NAMESPACE: "statsvc-env5"
K8S_ANNOTATIONS_log_filter_enabled: "true"
K8S_ANNOTATIONS_log_level_filter_pattern: "DEBUG|ERROR"
```

### Fluentd Pipeline

- Tails both log files.
- Applies an **annotation filter stage**:
  - Drops logs if `kubernetes.annotations.log_filter_enabled` is `false`.
  - Filters log levels dynamically via regex from `kubernetes.annotations.log_level_filter_pattern`.
- Forwards logs that pass filtering into namespace-specific branches, merging results into `fluentd-filtered-logs/merged.log`.

## Usage

1. Start the environment:
   ```bash
   docker compose up -d
   ```
2. Inspect raw logs:
   - `file-logger-logs/app-a.log`
   - `file-logger-logs/app-b.log`
3. View merged, annotation-filtered logs in:
   - `fluentd-filtered-logs/merged.log`

## Notes

- Hardcoded filtering rules were **removed**.  
- Filtering logic is now **controlled by annotations**, enabling workload-specific log selection without modifying `fluent.conf`.