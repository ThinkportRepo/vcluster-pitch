









### Prometheus & Grafana
kubectl port-forward -n prometheus prometheus-prometheus-kube-prometheus-prometheus-0 9090 --address=0.0.0.0

kubectl port-forward -n prometheus prometheus-grafana-6787c765d8-9n7vb 3000 --address=0.0.0.0