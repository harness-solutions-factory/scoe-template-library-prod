# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.4.2] - 2026-11-12

### Added
- Pipeline Executor Service Account automation in harness-project with API key rotation and multi-level role assignments
- HSF_IACM role templates (Admin, Approval, User) and Infrastructure As Code permission set to harness-project
- Infrastructure As Code permission set to harness-project
- Comprehensive RBAC templates to hsf-plugins-project (15+ permission sets including AI SRE, Administrative Functions, Artifact Registry, Chaos, Cloud Development Environments, Continuous Error Tracking, Database DevOps, Developer Portal, Discovery, Environments, Feature Flag Management, GitOps, Governance Policy, Harness Code Repository, Input Sets, Monitoring, Pipelines, Security Orchestration, Service Reliability, Services, Shared Resources, Software Engineering Insights, Supply Chain Security, and Webhooks)
- HSF_Code_Reviewers group template to hsf-plugins-project
- Example role templates to hsf-plugins-project (FF_Manager, FF_User, Policy_Manager, Release_Manager)
- HSF_Lab_Infrastructure_Users account-level group to harness-platform-setup
- Governance and policy configuration for harness-project and hsf-plugins-project

### Updated
- harness-project to support passing in additional template paths and group notifications from upstream templates
- harness-project with improved executor identity service account setup and configuration
- hsf-plugins-project to use improved resource management and module support
- hsf-plugins-project with enhanced RBAC and policy management capabilities

## [v1.4.1] - 2026-11-10

- FIX: Modify executor_identity in harness-project to use a group with extended permissions
- FIX: auto-abort previous execution when trigger is updated

## [v1.4.0] - 2026-11-10

- Add harness-platform-setup template

## [v1.3.0] - 2026-11-10

- Add SCOE Organization and HSF Default Organization templates

## [v1.2.0] - 2026-11-09

- Add HSF plugins and default project templates

## [v1.1.0] - 2026-11-09

- Add HSF Python Plugin template

## [v1.0.0] - 2026-11-001
_Initial Repository Setup_
