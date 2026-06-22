# Dependabot Configuration and Vulnerability Investigation

## Overview
This document tracks the Dependabot vulnerability investigation and setup for automatic version updates.

## Current Vulnerabilities

### aws-sdk (Low Severity)
- **Advisory ID**: GHSA-j965-2qgj-vjmq
- **Severity**: Low (CVSS 3.7)
- **Issue**: JavaScript SDK v2 users should add validation to the region parameter value or migrate to v3
- **Package**: aws-sdk (Direct dependency)
- **Current Version**: Removed in favor of AWS SDK for JavaScript v3 clients
- **Status**: Resolved by migrating the deploy script to AWS SDK v3 clients

#### Details
The vulnerability is related to the use of specific values for the region input field when calling AWS services. An actor with access to the environment could set the region input field to an invalid value. AWS SDK for JavaScript v2 reached end-of-support on September 8, 2025.

#### Resolution
1. **Migrated to AWS SDK for JavaScript v3** - The deployment script now uses `@aws-sdk/client-s3` and `@aws-sdk/client-cloudfront`
2. **Preserved existing deployment behavior** - S3 uploads still set the object ACL to `public-read`, and CloudFront invalidations still run as before
3. **Followed AWS security best practices** - Deployment credentials and regions continue to come from the existing environment configuration

## Dependabot Configuration

### Setup
Created `.github/dependabot.yml` to:
- Enable automatic version updates for npm dependencies (weekly on Mondays at 03:27 UTC)
- Enable automatic version updates for GitHub Actions (weekly on Mondays at 04:42 UTC)
- Group minor and patch updates to reduce PR volume
- Optionally assign PRs to specific maintainers when needed
- Apply consistent labeling for dependency management

### Features
- **Update Frequency**: Weekly on Mondays
- **PR Limit**: Up to 5 open PRs per ecosystem
- **Grouping**: Minor and patch updates are grouped together
- **Labels**: Applied for easy categorization (dependencies, ci)
- **Assignment**: Use assignees when you want dependency PRs routed to a specific maintainer or queue

## Next Steps

1. ✅ Created .github/dependabot.yml configuration
2. ✅ Documented the aws-sdk vulnerability
3. Plan for aws-sdk upgrade when AWS SDK v3 is fully tested with the application
4. Monitor Dependabot PRs for weekly updates

## AWS SDK Migration Timeline

- **Current**: Using aws-sdk v2 with the known vulnerability
- **Short-term**: Assess compatibility with the current aws-sdk v2 dependency and evaluate security update options
- **Medium-term**: Plan and execute migration to AWS SDK for JavaScript v3
  - This will require significant testing as it's a major version change
  - May require code refactoring due to API changes between v2 and v3
