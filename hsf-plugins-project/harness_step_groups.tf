resource "harness_platform_template" "HAR_Supply_Chain_Security" {
  depends_on   = [harness_time_sleep.project_setup]
  identifier   = "HAR_Supply_Chain_Security"
  name         = "HAR - Supply Chain Security"
  org_id       = module.harness_project.organization_identifier
  project_id   = module.harness_project.project_identifier
  version      = "v1"
  is_stable    = true
  force_delete = true
  template_yaml = templatefile(
    "${path.module}/templates/step_groups/stg_HAR_Supply_Chain_Security.yaml",
    {
      TEMPLATE_IDENTIFIER : "HAR_Supply_Chain_Security"
      TEMPLATE_NAME : "HAR - Supply Chain Security"
      TEMPLATE_VERSION : "v1"
      ORGANIZATION_ID : module.harness_project.organization_identifier
      PROJECT_ID : module.harness_project.project_identifier
      TEMPLATE_DESC : "Generate SBOM , SLSA and Artifact Signing . This Template also uses cosign so you have to generate cosign private , public key and password to be stored in Harness"

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}

resource "harness_platform_template" "Python_Containers_Build_Scan_Publish_to_HAR" {
  depends_on   = [harness_time_sleep.project_setup]
  identifier   = "Python_Containers_Build_Scan_Publish_to_HAR"
  name         = "Python Containers - Build Scan Publish to HAR"
  org_id       = module.harness_project.organization_identifier
  project_id   = module.harness_project.project_identifier
  version      = "v1"
  is_stable    = true
  force_delete = true
  template_yaml = templatefile(
    "${path.module}/templates/step_groups/stg_Python_Containers_Build_Scan_Publish_to_HAR.yaml",
    {
      TEMPLATE_IDENTIFIER : "Python_Containers_Build_Scan_Publish_to_HAR"
      TEMPLATE_NAME : "Python Containers - Build Scan Publish to HAR"
      TEMPLATE_VERSION : "v1"
      ORGANIZATION_ID : module.harness_project.organization_identifier
      PROJECT_ID : module.harness_project.project_identifier
      TEMPLATE_DESC : "Requires SCOE Python Application Structure. Standard Build and Scan of Containers for Python Modules. When marked for Release, then will publish new images"

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}

resource "harness_platform_template" "Python_Build_Test_Publish_to_HAR" {
  depends_on   = [harness_time_sleep.project_setup]
  identifier   = "Python_Build_Test_Publish_to_HAR"
  name         = "Python - Build-Test-Publish to HAR"
  org_id       = module.harness_project.organization_identifier
  project_id   = module.harness_project.project_identifier
  version      = "v1"
  is_stable    = true
  force_delete = true
  template_yaml = templatefile(
    "${path.module}/templates/step_groups/stg_Python_Build_Test_Publish_to_HAR.yaml",
    {
      TEMPLATE_IDENTIFIER : "Python_Build_Test_Publish_to_HAR"
      TEMPLATE_NAME : "Python - Build-Test-Publish to HAR"
      TEMPLATE_VERSION : "v1"
      ORGANIZATION_ID : module.harness_project.organization_identifier
      PROJECT_ID : module.harness_project.project_identifier
      TEMPLATE_DESC : "Requires SCOE Python Application Structure. Standard Build and Unit Test execution for Python Modules."

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}

resource "harness_platform_template" "Code_Smells_and_Linting" {
  depends_on   = [harness_time_sleep.project_setup]
  identifier   = "Code_Smells_and_Linting"
  name         = "Code Smells and Linting"
  org_id       = module.harness_project.organization_identifier
  project_id   = module.harness_project.project_identifier
  version      = "v1"
  is_stable    = true
  force_delete = true
  template_yaml = templatefile(
    "${path.module}/templates/step_groups/stg_Code_Smells_and_Linting.yaml",
    {
      TEMPLATE_IDENTIFIER : "Code_Smells_and_Linting"
      TEMPLATE_NAME : "Code Smells and Linting"
      TEMPLATE_VERSION : "v1"
      ORGANIZATION_ID : module.harness_project.organization_identifier
      PROJECT_ID : module.harness_project.project_identifier
      TEMPLATE_DESC : "This is the template which does your code scans and smell checks"

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}
