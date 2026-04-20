# shorten-url-infra

AWS infrastructure for [short.manamperi.com](https://short.manamperi.com) — a serverless 
URL shortener built as a portfolio project demonstrating a production-grade AWS architecture 
with full CI/CD.

## Live demo

Visit [short.manamperi.com](https://short.manamperi.com) to try it out.

## Architecture

```
Browser
    → CloudFront (CDN, SSL, custom domain)
        ├── / and /index.html → S3 (static frontend)
        └── /* → API Gateway HTTP API
                    ├── POST /shorten → create_short_url Lambda
                    └── GET /{code}  → redirect Lambda
                                            → DynamoDB
```

## Tech stack

| Layer | Technology |
|---|---|
| CDN | AWS CloudFront |
| DNS & SSL | Namecheap DNS, AWS ACM |
| API | AWS API Gateway HTTP API |
| Compute | AWS Lambda (Python 3.11, Docker) |
| Database | AWS DynamoDB |
| Networking | AWS VPC, private subnets |
| Container registry | Amazon ECR |
| Infrastructure | Terraform >= 1.14 |
| State management | S3 with native locking |
| CI/CD | GitHub Actions with OIDC |

## Repository structure

```
shorten-url-infra/
├── terraform/                  # Main infrastructure — managed by CI/CD
│   ├── modules/
│   │   ├── vpc/                # VPC, subnets, security groups
│   │   ├── lambda/             # Lambda functions, DynamoDB, IAM, SSM
│   │   └── api_gateway/        # API Gateway HTTP API
│   ├── cloudfront.tf           # CloudFront distribution
│   ├── remote_states.tf        # Remote state data sources
│   ├── budgets.tf              # AWS Budgets cost alert
│   └── ...
└── terraform-manual/           # One-time manual setup
    └── acm_certificate.tf      # ACM certificate for custom domain
```

## CI/CD pipeline

### On pull request
1. `terraform validate` — checks configuration syntax
2. `terraform plan` — shows infrastructure changes

### On merge to main
1. `terraform validate`
2. `terraform apply` — applies infrastructure changes
3. Lambda functions automatically updated if new ECR image digest detected

## Security

- **OIDC authentication** — no static AWS credentials stored in GitHub
- **Private VPC** — Lambda functions run in private subnets
- **Least privilege IAM** — scoped permissions per resource
- **API Gateway throttling** — rate limiting to prevent abuse
- **DynamoDB TTL** — short URLs automatically expire after 3 days
- **AWS Budgets** — email alert if monthly spend exceeds threshold
- **URL validation** — both frontend and Lambda validate submitted URLs
- **CloudFront** — AWS Shield Standard DDoS protection included free

## Local development

### Prerequisites
- AWS CLI with `projects` profile
- Terraform >= 1.14
- GNU Make

### Common commands

```bash
make init        # initialise Terraform backend
make plan        # show planned changes
make apply       # apply changes
make destroy     # destroy all resources
make validate    # validate Terraform syntax
make fmt         # format Terraform files
```

### Manual setup (one-time)

The ACM certificate for the custom domain is managed separately:

```bash
make manual-init
make manual-apply
# Add CNAME records to your DNS provider
# Wait for certificate validation
```

## Cost

This project runs almost entirely within the AWS free tier:

| Resource | Cost |
|---|---|
| Lambda | Free tier (1M requests/month) |
| API Gateway | Free tier (1M requests/month) |
| DynamoDB | Free tier (25GB storage) |
| CloudFront | Free tier (1TB transfer/month) |
| S3 | Negligible |
| ECR | Free tier (500MB/month) |
| ACM certificate | Free |
| CloudFront custom domain | $1.00/month |

## Related projects

- [aws-terraform-bootstrap](https://github.com/yourusername/aws-terraform-bootstrap) — Shared AWS bootstrap (OIDC role, S3 state bucket)
- [shorten-url-app](https://github.com/yourusername/shorten-url-app) — Application code, Docker images, frontend
