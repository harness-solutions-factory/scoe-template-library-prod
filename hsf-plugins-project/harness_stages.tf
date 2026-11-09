resource "harness_platform_template" "Python_Application_Build_with_Container_Image" {
  depends_on   = [harness_time_sleep.step_groups]
  identifier   = "Python_Application_Build_with_Container_Image"
  name         = "Python Application Build with Container Image"
  org_id       = module.harness_project.organization_identifier
  project_id   = module.harness_project.project_identifier
  version      = "v2"
  is_stable    = true
  force_delete = true
  template_yaml = templatefile(
    "${path.module}/templates/stages/sta_Python_Application_Build_with_Container_Image.yaml",
    {
      TEMPLATE_IDENTIFIER : "Python_Application_Build_with_Container_Image"
      TEMPLATE_NAME : "Python Application Build with Container Image"
      TEMPLATE_VERSION : "v2"
      ORGANIZATION_ID : module.harness_project.organization_identifier
      PROJECT_ID : module.harness_project.project_identifier
      TEMPLATE_DESC : "Build, Scan, and Quailfy Python Applications with container images"

      TAGS : yamlencode(local.common_tags)
    }
  )
  tags = local.common_tags_tuple
}
