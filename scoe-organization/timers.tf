# When creating a new organization, there is a potential race-condition
# as the organization comes up.  This resource will introduce
# a slight delay in further execution to wait for the resources to
# complete.
resource "harness_time_sleep" "org_setup" {
  depends_on = [
    module.harness_organization
  ]

  create_duration = "15s"
}
# resource "harness_time_sleep" "step_groups" {
#   depends_on = [
#     harness_platform_template.HAR_Supply_Chain_Security,
#     harness_platform_template.Python_Containers_Build_Scan_Publish_to_HAR,
#     harness_platform_template.Python_Build_Test_Publish_to_HAR,
#     harness_platform_template.Code_Smells_and_Linting,
#   ]

#   create_duration  = "15s"
#   destroy_duration = "5s"
# }
