# xnat-k8s-prototype

## 🚀 Deployment
0. Create a `.env` file from `.env.sample` and ensure Cloudflare TLS is in 'flexible' mode
1. Run `make aws`

## Notes
- Storage class must support `ReadWriteMany`
- Images built: https://github.com/Australian-Imaging-Service/xnat-docker-build/blob/main/Dockerfile
