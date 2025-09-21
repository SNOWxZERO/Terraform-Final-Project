resource "null_resource" "generate_ips" {
  depends_on = [aws_instance.servers]

  provisioner "local-exec" {
    command = <<-EOT
      echo "public-ip1 ${aws_instance.servers["proxy1"].public_ip}" > all-ips.txt
      echo "public-ip2 ${aws_instance.servers["proxy2"].public_ip}" >> all-ips.txt
      echo "private-ip1 ${aws_instance.servers["backend1"].private_ip}" >> all-ips.txt
      echo "private-ip2 ${aws_instance.servers["backend2"].private_ip}" >> all-ips.txt
    EOT
  }
}