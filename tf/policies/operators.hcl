%{ for cluster in managed_clusters }
# Allow the operators to update in in the ${cluster} directory
path "secret/${cluster}/operators" {
  capabilities = ["update"]
}

%{ endfor }
