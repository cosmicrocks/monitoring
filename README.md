## Prometheus operator and kube-prometheus
One of the great things about the Kubernetes architecture that it’s a system composed from independent components decoupled from each other this is very nice of course for the right reasons but it makes the task of properly setting up monitoring and alerting for all of the various cluster components not so easy as you figure out very quickly that these components generate a lot of metrics and that’s even before we started talking about our own services.

This is where prometheus operator and the awesome kube-prometheus projects comes to the rescue saving a lot of time getting up and running with a production ready setup.

```
kubectl apply -k https://github.com/cosmicrocks/monitoring.git
```

### port-forward to grafana
```
kubectl -n monitoring port-forward $(kubectl -n monitoring get pods -l app=grafana -o jsonpath='{.items[*].metadata.name}') 3000:3000 &

and browse to https://127.0.0.1:3000
(username and password are 'admin')
```