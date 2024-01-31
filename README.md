# Vcluster pitch
***
Short Description about the project.
# Vcluster Projektübersicht

## Kurzbeschreibung







## Bereitstellung der AWS Cloud Komponenten
## Voraussetzungen
Bevor Sie beginnen, stellen Sie sicher, dass folgende Tools auf Ihrem System installiert sind:
- Terraform-cli
- AWS-cli
- vcluster-cli
- kubectl

Zusätzlich benötigen Sie ein AWS-Konto und entsprechende Berechtigungen, 
um Ressourcen zu erstellen und zu verwalten.
## Bereitstellung der AWS Cloud Komponenten

### Schritt 1: Vorbereitung
Wechseln Sie in das Verzeichnis `infrastructur-aws/eks-cluster-v`:
```bash
cd infrastructur-aws/eks-cluster-v/
```

### Schritt 2: Infrastruktur aufbauen
Führen Sie die folgenden Befehle aus, um die Infrastruktur mit Terraform zu initialisieren und zu erstellen:

```bash
terraform init
terraform plan
terraform apply
```
### Schritt 3: AWS Zugangsdaten abrufen
Abrufen der Zugangsdaten für AWS Administratoren. Dies ermöglicht die Verwaltung der erstellten Ressourcen.
![Get credentials for AdministratorAccess!](readme-img/Get_credentials_AdministratorAccess.png "Get credentials for AdministratorAccess")


### Schritt 4: AWS-Umgebungsvariablen konfigurieren
Konfigurieren Sie Kurzzeit-Anmeldeinformationen in Ihrem Terminal:

```
aws eks --region eu-central-1 update-kubeconfig --name main-eks-vcluster
```
### Schritt 5: vcluster auflisten und verbinden
Liste alle verfügbaren vcluster auf und stelle eine Verbindung her:

```
vcluster list
vcluster connect admin-vcluster
```
![vcluster list!](readme-img/vcluster-list.png "vcluster list")

### Schritt 6: Verbindung mit vCluster
Stellen Sie eine Verbindung zum vCluster her und nutzen Sie diesen (vcluster connect [vcluster-name]):
```
vcluster connect admin-vcluster
```
![vcluster list!](readme-img/connect-vcluster.png "vcluster list")
### Schritt 7: Neue Terminal-Session
Lassen Sie den Terminal offen und öffnen Sie einen neuen Terminal. Führen Sie dort aus:
```
kubectl get namespaces
```
### Schritt 8: Deployment von Testanwendungen
Navigieren Sie zum Ordner TESTS, um den nginx, seinen Service und Ingress zu deployen:
```
kubectl create -f testing-v-admin-isolation.yaml
```
### Schritt 9: SERVICE-IP abrufen
Abrufen und Kopieren der SERVICE-IP (Port 8080):
```
kubectl get services -o wide
```
![Service IP-Address!](readme-img/test-pod-svc-ip.png "Service IP-Address")

### Schritt 10: Wechsel zum Host Cluster
Trennen Sie die Verbindung zum vcluster und wechseln Sie zum Host Cluster:

```
vcluster disconnect
```
Kehren Sie zum ersten Terminal zurück und verwenden Sie ***CTRL+C***.

### Schritt 11: Verbindung mit dem dev-vcluster
Stellen Sie die Verbindung mit dem dev-vcluster her:

```
vcluster connect dev-vcluster
```
### Schritt 12: Tests durchführen
Führen Sie Tests durch:
```
kubectl run tmp-pod --image=busybox -it --rm --restart=Never -- wget -O- [SERVICE-IP]:8080
```
Trennen Sie nach Abschluss aller Tests die Verbindung vom vcluster (vcluster disconnect).

## Prometheus & Grafana
Zur Überwachung des Clusters stehen Prometheus und Grafana zur Verfügung:
### Schritt 1: Verbindung mit Prometheus
Verbinden Sie sich zuerst mit Prometheus:
```
kubectl port-forward -n prometheus prometheus-prometheus-kube-prometheus-prometheus-0 9090 --address=0.0.0.0
```
### Schritt 2: Verbindung mit Grafana
Öffnen Sie einen anderen Terminal und verbinden Sie sich mit Grafana. Ersetzen Sie [*] durch den Rest des Grafana-Pod-Namens:

```
kubectl get pod -n prometheus
```
```
kubectl port-forward -n prometheus prometheus-grafana-[*] 3000 --address=0.0.0.0
```
## Grafana Dashboard Zugriff
Nachdem Sie Grafana erfolgreich verbunden haben, können Sie auf das Grafana Dashboard wie folgt zugreifen:
### Schritt 1: Grafana-Dashboard öffnen
Öffnen Sie einen Webbrowser und geben Sie die URL http://0.0.0.0:3000 ein. Dies leitet Sie zur Grafana-Anmeldeseite.
### Schritt 2: Anmeldung bei Grafana
Verwenden Sie die folgenden Anmeldedaten, um sich bei Grafana anzumelden:

Benutzername: admin
Passwort: prom-operator

### Schritt 3: Grafana Dashboard nutzen
Nach erfolgreicher Anmeldung haben Sie Zugriff auf das Grafana Dashboard. 
Hier können Sie verschiedene Dashboards zur Überwachung Ihrer Clusterressourcen und -metriken nutzen.


[//]: # ()
[//]: # (Test Scenario)

[//]: # (#TODO Nginx mit ingress auf v-admin von v-dev auf v-admin zugreifen)

[//]: # (vcluster connect v-admin --namespace administration)

[//]: # (kubectl apply -f testing-v-admin-isolation.yaml)

[//]: # (kubectl get svc)

[//]: # (NAMESPACE       NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP   PORT&#40;S&#41;                      AGE    SELECTOR)

[//]: # (kube-system     kube-dns                   ClusterIP      10.43.107.200   <none>        53/UDP,53/TCP,9153/TCP       22h    k8s-app=kube-dns)

[//]: # (default         kubernetes                 ClusterIP      10.43.245.97    <none>        443/TCP                      22h    <none>)

[//]: # (default         isolation-test-svc         ClusterIP      10.43.224.183   <none>        80/TCP                       108m   app=iso-test)

[//]: # (nginx-ingress   nginx-ingress-controller   LoadBalancer   10.43.1.128     <pending>     80:32163/TCP,443:32373/TCP   101m   app.kubernetes.io/instance=nginx-ingress,app.kubernetes.io/name=nginx-ingress)

[//]: # ()
[//]: # (kubectl run tmp-pod --image=busybox -it --rm --restart=Never -- wget -O- 10.43.224.183)

[//]: # (# kubectl patch svc nginx-ingress-controller -n nginx-ingress -p '{"spec": {"type": "LoadBalancer", "externalIPs":["192.168.99.100"]}}')

[//]: # (```)

[//]: # (vcluster create v-admin -n administration --create-namespace=true --connect=false --isolate=true -f admin-values.yaml)

[//]: # (vcluster create v-admin -n administration --create-namespace=true --connect=false --isolate=true)

[//]: # (```)

[//]: # (vcluster connect v-admin --namespace administration)

[//]: # (kubectl patch svc isolation-test-svc -p '{"spec": {"type": "LoadBalancer", "externalIPs":["192.168.99.100"]}}')

[//]: # (```)

[//]: # (vcluster connect v-admin --namespace administration)

[//]: # (```)

[//]: # ()
[//]: # (#TODO Kosten vergleich zwischen vcluster und cluster basiertend multi-tenancy)

[//]: # (#TODO mit netzwerk alle pods ip testen entweder mit netstat oder mit wireshark)

[//]: # (#TODO CHECK: Service sind nicht zugreifbar außerhalb vcluser)

[//]: # (aws eks --region eu-central-1 update-kubeconfig --name main-eks-vcluster)

[//]: # ()
[//]: # (#TODO Vollständige isollierung mit networkpolicy)

[//]: # (#TODO Für networkpolicy für Terraform)

[//]: # (#Dokumentation)

[//]: # (#Readme)


