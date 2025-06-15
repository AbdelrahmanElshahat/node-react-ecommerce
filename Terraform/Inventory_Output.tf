#  resource "null_resource" "print_ips" {
#     depends_on = [module.Eks_Cluster_Module.worker-node-group]
#   provisioner "local-exec" {
#     command = <<EOT
#       cat <<EOF > ../Ansible/my_inventory.ini
# [Jenkins_EC2]
# ${module.Jenkin_EC2_Module.Jenkins_public_ip}

# [Worker_Nodes_EC2]
# ${module.Eks_Cluster_Module.worker_node_public_ips[0]}
# ${module.Eks_Cluster_Module.worker_node_public_ips[1]} 
#     EOT
#   }  
#  }

resource "null_resource" "print_ips" {
  depends_on = [module.Jenkin_EC2_Module]  

  provisioner "local-exec" {
    command = <<EOT
      cat <<EOF > /home/mennatullah/Documents/ITI_Graduation_project/IAC/Ansible/my_inventory.ini
[Jenkins_EC2]
${module.Jenkin_EC2_Module.Jenkins_public_ip}

EOF
    EOT
  }
}
