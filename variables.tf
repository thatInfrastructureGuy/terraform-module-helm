variable "host" {
  description = "kubernetes_host"
}

variable "client_certificate" {
  description = "kubernetes_client_certificate"
}

variable "client_key" {
  description = "kubernetes_client_key"
}

variable "cluster_ca_certificate" {
  description = "kubernetes_ca_certificate"
}

variable "nginx_helm_release_name" {
  description = "Helm release name"
  default     = "prod-proxy"
}

variable "nginx_helm_namespace" {
  description = "Nginx deployment Namespace"
  default     = "nginx-proxy"
}

variable "nginx_helm_values_file" {
  description = "values.yaml file for helm chart"
  default     = ""
}

variable "load_balancer_ip" {
  description = "Static IP if allocated"
  default     = ""
}
