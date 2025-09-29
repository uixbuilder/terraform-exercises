# Logs Collecting with Fluent Bit

This project contains Kubernetes manifests and Docker Compose setups to experiment with log collection using **Fluent Bit**, Elasticsearch, and Kibana.

## Repository Structure

```
logs-collecting-with-fluent-bit/
├── pod-apache-logs.yaml                # Pod manifest generating sample Apache logs
├── README.md                           # Documentation and usage
├── elastic-search/                     # Elasticsearch manifests
│   ├── elasticsearch-configmap.yaml
│   ├── elasticsearch-deployment.yaml
│   ├── elasticsearch-pvc.yaml
│   └── elasticsearch-service.yaml
├── elastic-search-kibana/              # Kibana manifests (with ES connection)
│   ├── elasticsearch-kibana.yaml
│   ├── Kibana-configmap.yaml
│   └── Kibana-service.yaml
└── fluent-bit/                         # Fluent Bit manifests
    ├── fluent-bit-configmap.yaml
    ├── fluent-bit-ds-minikube.yaml
    └── logging-namespace.yml
```

## Notes
- Fluent Bit tails Kubernetes container logs from `/var/log/containers/*.log`.
- Logs are forwarded to Elasticsearch and stored in indices matching `logstash-*`.
- In Kibana, create a **data view** (`logstash-*`) with `@timestamp` as the time field to see logs.

## Resources

- [Fluent Bit Documentation](https://docs.fluentbit.io/)
- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/index.html)
- [Kibana Documentation](https://www.elastic.co/guide/en/kibana/current/index.html)

### Example View in Kibana

Below is a screenshot of logs successfully ingested and displayed inside Kibana:

<img src="kibana.png" alt="Kibana Logs View" width="800"/>

## Resources
- https://www.youtube.com/watch?v=7qL5wkAaSh4
- https://medium.com/@ismailwajdi39/deploying-elasticsearch-and-kibana-on-kubernetes-with-password-protection-fad93010563c
## Pod-level Filtering with Annotations

You can control Fluent Bit log collection per pod using Kubernetes annotations:

```yaml
metadata:
  annotations:
    fluentbit.io/exclude: "true"
```

This annotation tells Fluent Bit to **exclude logs from this pod**.

You can also specify which parser to apply for pod logs:

```yaml
metadata:
  annotations:
    fluentbit.io/parser: apache
```

This applies the `apache` parser for the pod’s logs, ensuring proper parsing and filtering.

## Example: Apache Log Parsing

The file [`pod-apache-logs.yaml`](pod-apache-logs.yaml) creates a pod that generates sample Apache access logs.
By applying the `fluentbit.io/parser: apache` annotation, these logs are parsed into structured fields (e.g. `client`, `method`, `path`, `status`).

This makes it possible to filter HTTP traffic in Kibana by **status codes**, **URLs**, and **request methods** rather than raw log lines.

### Steps:
1. Deploy the sample Apache pod:
   ```sh
   kubectl apply -f pod-apache-logs.yaml
   ```
2. Ensure your Fluent Bit `ConfigMap` contains the `apache` parser definition.
3. Check Kibana → Discover for logs structured as Apache fields.

✅ With this setup, troubleshooting web requests becomes easier since errors (e.g., `500` responses) and endpoints can be quickly identified.
