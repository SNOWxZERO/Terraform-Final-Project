# Terraform Project Deployment

## 1. Creating the S3 Bucket for tfstate

![S3 Bucket Creation](<WhatsApp Image 2025-09-22 at 22.57.39_ceef1466.jpg>)

---

## 2. Initializing the Main Project

![Terraform Init](<WhatsApp Image 2025-09-22 at 23.09.54_8d867af5.jpg>)

---

## 3. Changing Workspace

![Terraform Workspace Change](<WhatsApp Image 2025-09-22 at 23.10.54_f76c9c3f.jpg>)

---

## 4. Running `terraform apply`

![Terraform Apply - Part 1](<WhatsApp Image 2025-09-22 at 23.12.46_4a22151c.jpg>)  
![Terraform Apply - Part 2](<WhatsApp Image 2025-09-22 at 23.18.07_3d456f2b.jpg>)

---

## 5. Accessing the Public ALB DNS

![Public ALB DNS - Page 1](<WhatsApp Image 2025-09-22 at 23.19.10_1de2f175.jpg>)  
![Public ALB DNS - Page 2](<WhatsApp Image 2025-09-22 at 23.19.22_98c5ed9a.jpg>)

---

## 6. Accessing the Internal ALB DNS
![alt text]({67B586BC-106F-474A-81DF-EFC6C37FD32C}.png)

---

## 6. SSH Public instances
![alt text]({3FEDF475-9B40-4D36-A4D0-3908E459156F}.png)
![alt text]({519DC214-2A5F-40A7-AC6C-97F975D6F032}.png)


## 7. SSH Private instances
i forgot to add the key in the public instance so i coppied it through scp :D
and no i connect to private instance through the public instance

### first one
![alt text]({C42C39B6-A733-4C9B-B3C6-74FB3E5FB8C4}.png)

## second one
![alt text]({B4B1F5A9-293F-49DB-9CED-A3B5A9C47A27}.png)

---

## 7. Destroying resources

![alt text]({A0CB59EF-D6AE-476B-A931-F945F053C6AB}.png)

---
