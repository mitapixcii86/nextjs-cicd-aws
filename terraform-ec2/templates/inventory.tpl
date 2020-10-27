[ip_instance]
${instance_ip}

[all:vars]
ansible_ssh_private_key_file = ${key_path}
ansible_ssh_user = ubuntu