# xnat-k8s-prototype

## 🚀 Deployment
### Prerequisites
- An AWS account with a VPC containing a public subnet
- A Cloudflare account containing a DNS zone

### Steps
0. Create a `.env` file from `.env.sample` and ensure Cloudflare TLS is in 'flexible' mode
1. Run `make deploy`

## Notes
- Storage class must support `ReadWriteMany`
- Images built: https://github.com/Australian-Imaging-Service/xnat-docker-build/blob/main/Dockerfile
