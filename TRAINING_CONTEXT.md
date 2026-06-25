# Kubernetes Training Context — EKS Cluster with Terraform

## Estilo de interacción
- No generar código directamente — el estudiante lo escribe
- Retar el pensamiento crítico con preguntas antes de dar respuestas
- Cuando el estudiante está en territorio genuinamente desconocido, dar contexto y mapa primero
- No dar respuestas masticadas, pero sí orientación cuando hay bloqueo real
- Pedir que el estudiante explique conceptos con sus propias palabras antes de avanzar

---

## Conceptos ya establecidos

### Terraform
- Terraform usa enfoque **declarativo** vs bash que es **imperativo**
- El **statefile** es un archivo JSON que refleja el estado real de la infraestructura
- Si el statefile se pierde, Terraform no ve la infraestructura existente y podría intentar recrearla, causando duplicados o destrucción
- El statefile debe vivir en un backend remoto (S3, etc.) con las propiedades: durabilidad, control de acceso, y locking para evitar escrituras concurrentes
- `.terraform/` contiene providers y módulos descargados — no es donde vive el statefile

### EKS — Conceptos generales
- **Control plane** — gestionado completamente por AWS, invisible para el usuario
- **Data plane** — donde corren los pods, responsabilidad del usuario

### EKS Auto Mode
- AWS gestiona nodos, autoscaling, tipo de instancia, y terminación
- Se pierde granularidad y control
- Válido para equipos con workloads estándar o equipos pequeños
- No válido para workloads especializados (GPU, networking custom)
- El criterio real no es el ambiente (dev/prod) sino la madurez del equipo y los requisitos del workload

### Managed Node Groups vs Self-managed vs Fargate
- **Managed Node Groups** — AWS gestiona lifecycle, AMI updates, rolling updates, y el Auto Scaling Group subyacente
- **Self-managed** — el ingeniero gestiona AMI, kubeadm join, parches, todo
- **Fargate** — serverless, sin nodos visibles

### Cluster Autoscaler vs Karpenter
- **Cluster Autoscaler** — habla con el Auto Scaling Group para escalar nodos. Camino tradicional
- **Karpenter** — provisiona instancias EC2 directamente, sin pasar por ASG. Más rápido y flexible. Reemplaza al Cluster Autoscaler completamente
- No se usan ambos al mismo tiempo — se elige uno

### Patrón arquitectónico elegido
**Managed Node Group pequeño + Karpenter**

- Un **Managed Node Group fijo** para componentes de sistema:
  - CoreDNS
  - AWS VPC CNI
  - Karpenter
  - Pod Identity Agent
  - Otros addons de sistema (monitoreo, logging, ingress)
- **Karpenter** gestiona el resto del data plane dinámicamente para workloads

> ⚠️ Pregunta pendiente: ¿Cuántos nodos debe tener el Managed Node Group inicial? El estudiante dijo "1" — se quedó pendiente razonar qué pasa cuando ese único nodo falla (disponibilidad, single point of failure)

### Networking
- Nodos en **subnets privadas**
- Tráfico externo entra por **Load Balancer**
- Nodos necesitan **NAT Gateway** para salir a internet (Docker Hub, paquetes externos)
- **VPC Endpoints** para servicios AWS (ECR, S3, STS, EC2, EKS API) eliminan necesidad de NAT para tráfico interno de AWS
- En producción la decisión es mantener ambos: VPC Endpoints para servicios AWS + NAT Gateway para internet pública

> ⚠️ Pregunta pendiente: ¿Eliminar NAT completamente o mantener ambos? Se pospuso conscientemente

### IAM — IRSA vs Pod Identity Agent
- Los pods obtienen permisos AWS a través de **Service Accounts** asociados a IAM Roles
- **IRSA** (IAM Roles for Service Accounts) — usa OIDC federation. Requiere OIDC provider por cluster. Fricción operacional alta en multi-cluster o multi-account
- **Pod Identity Agent** — agente que corre en cada nodo, actúa como intermediario con IAM. Similar a EC2 instance profiles. Menos fricción operacional
- Es un addon que debe instalarse en el cluster

> ⚠️ Pregunta pendiente: ¿Pod Identity Agent viene preinstalado o se instala como addon? ¿Cómo afecta al diseño del Managed Node Group inicial?

---

## Módulo Terraform en uso
[terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks)

---

## Preguntas abiertas para continuar
1. ¿Cuántos nodos en el Managed Node Group inicial y por qué? (disponibilidad)
2. ¿NAT Gateway + VPC Endpoints o solo VPC Endpoints en producción?
3. ¿Pod Identity Agent como addon — cómo se instala y qué implica para el arranque del cluster?
4. ¿Qué Availability Zones y cuántas para distribuir los nodos?
