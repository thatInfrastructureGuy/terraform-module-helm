//-----------------Kubernetes Init-------------------------
provider "kubernetes" {
    host                          = "${var.host}"
    client_certificate            = "${var.client_certificate}"
    client_key                    = "${var.client_key}"
    cluster_ca_certificate        = "${var.cluster_ca_certificate}"
    load_config_file              = false
}

//-----------------Tiller Namespace------------------------
//resource "kubernetes_namespace" "tiller_namespace" {
//  metadata {
//    name                          = "kube-system"
//  }
//}

//-----------------Tiller Service Account------------------
//resource "kubernetes_service_account" "tiller_service_account" {
//  metadata {
//    name                          = "default"
//    namespace                     = "kube-system"
//  }
//  automount_service_account_token = true  
//}

//-----------------Tiller RoleBinding----------------------
resource "kubernetes_cluster_role_binding" "tiller_cluster_role_binding" {
  metadata {
    name                          = "tiller"
  }
  role_ref {
    api_group                     = "rbac.authorization.k8s.io"
    kind                          = "ClusterRole"
    name                          = "cluster-admin"
  }
  subject {
    kind                          = "ServiceAccount"
    name                          = "default"
    namespace                     = "kube-system"
  }
}

//-----------------Helm Init-------------------------------
provider "helm" {
  install_tiller                  = true
  service_account                 = "default"
  namespace                       = "kube-system"
  tiller_image                    = "gcr.io/kubernetes-helm/tiller:v2.14.2"
  version                         = "~> 0.10"
  kubernetes {
    load_config_file              = false
    host                          = "${var.host}"
    client_certificate            = "${var.client_certificate}"
    client_key                    = "${var.client_key}"
    cluster_ca_certificate        = "${var.cluster_ca_certificate}"
  }
}

// Need atleast one helm release to install tiller
// See: https://github.com/terraform-providers/terraform-provider-helm/issues/148#issuecomment-474616099
// Remove Nginx helm into separate module after https://github.com/terraform-providers/terraform-provider-helm/pull/203 is merged.
//-----------------Nginx Helm Repo Location----------------
data "helm_repository" "stable" {
    name                     = "stable"
    url                      = "https://kubernetes-charts.storage.googleapis.com"
}

//-----------------Nginx Helm Configuration----------------
resource "helm_release" "nginx-ingress" {
  name                       = "${var.nginx_helm_release_name}"
  namespace                  = "${var.nginx_helm_namespace}"
  repository                 = "${data.helm_repository.stable.metadata.0.name}"
  chart                      = "nginx-ingress"
  version                    = "0.25.1"

  values                     = [ "${var.nginx_helm_values_file}" ]

  set {
    name                     = "controller.service.loadBalancerIP"
    value                    = "${var.load_balancer_ip}"
  }

}
