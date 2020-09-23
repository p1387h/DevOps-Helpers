# ----- AKS ------------------------------------------------

# The public ip is needed since setting the private endpoint for different 
# resources makes them not accessible from the internet. The current public 
# ip of the terraform computer is set in the allowed firewall ranges and 
# should be removed afterwards.
current_public_ip = "$CURRENT_PUBLIC_IP"