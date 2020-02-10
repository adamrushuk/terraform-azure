data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# resource "helm_release" "nexus" {
#   name       = "sonatype-nexus"
#   repository = data.helm_repository.stable.metadata[0].name
#   chart      = "stable/sonatype-nexus"
#   version    = "1.22.0"
# #   namespace  = "nexus"
# #   atomic     = true
# #   verify     = true
#   wait       = true

#   #   values = [
#   #     "${file("values.yaml")}"
#   #   ]

#   #   set {
#   #     name  = "cluster.enabled"
#   #     value = "true"
#   #   }

#   #   set {
#   #     name  = "metrics.enabled"
#   #     value = "true"
#   #   }

#   #   set_string {
#   #     name  = "service.annotations.prometheus\\.io/port"
#   #     value = "9127"
#   #   }
# }
