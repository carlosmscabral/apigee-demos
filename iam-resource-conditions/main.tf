/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#######################################################################
### Custom Apigee X Deploy and Debug Role
#######################################################################
resource "google_project_iam_custom_role" "CustomRoleApigeeXDeployDebug" {
  project = "${var.project_id}"
  role_id     = "CustomRoleApigeeXDeployDebug"
  title       = "Custom Role Apigee X Deploy and Debug"
  description = "Custom role for Apigee X fine grained access with deployment and debug"
  permissions = [
    "apigee.deployments.get",
    "apigee.deployments.list",
    "apigee.environments.get",
    "apigee.environments.list"
  ]
}


#######################################################################
### Role assignment to BU 1 user
#######################################################################
resource "google_project_iam_member" "business_unit_1_custom_role" {
  project = "${var.project_id}"
  role    = "projects/${var.project_id}/roles/CustomRoleApigeeXDeployDebug"
  member  = "user:bu1-user@${var.domain}"
}

resource "google_project_iam_member" "business_unit_1_api_admin" {
  project = "${var.project_id}"
  role    = "roles/apigee.apiAdminV2"
  member  = "user:bu1-user@${var.domain}"

  condition {
    title       = "bu1 custom"
    description = "Conditions for business unit to edit bu1- prefixed proxies, shared flows and test"
    expression  = "resource.name.startsWith('organizations/${var.project_id}/apis/bu1-') ||\nresource.name.startsWith('organizations/apigeex-exp/sharedflows/bu1-') ||\nresource.name.startsWith('organizations/apigeex-exp/apiproducts/bu1-') ||\n(resource.type == 'apigee.googleapis.com/Developer') ||\n(resource.type == 'apigee.googleapis.com/DeveloperApp' && resource.name.extract('/apps/{name}').startsWith('bu1-')) ||\nresource.type == 'cloudresourcemanager.googleapis.com/Project'"
  }
}

resource "google_project_iam_member" "business_unit_1_developer_admin" {
  project = "${var.project_id}"
  role    = "roles/apigee.developerAdmin"
  member  = "user:bu1-user@${var.domain}"

  condition {
    title       = "bu1 custom"
    description = "Conditions for business unit to edit bu1- prefixed proxies, shared flows and test"
    expression  = "resource.name.startsWith('organizations/${var.project_id}/apis/bu1-') ||\nresource.name.startsWith('organizations/apigeex-exp/sharedflows/bu1-') ||\nresource.name.startsWith('organizations/apigeex-exp/apiproducts/bu1-') ||\n(resource.type == 'apigee.googleapis.com/Developer') ||\n(resource.type == 'apigee.googleapis.com/DeveloperApp' && resource.name.extract('/apps/{name}').startsWith('bu1-')) ||\nresource.type == 'cloudresourcemanager.googleapis.com/Project'"
  }
}

#######################################################################
### Environment Access for BU 1
#######################################################################
resource "google_apigee_environment_iam_member" "bu1-dev-env" {
  org_id = "organizations/${var.project_id}"
  env_id = "dev"
  role = "roles/apigee.environmentAdmin"
  member = "user:bu1-user@${var.domain}"
}

# #######################################################################
# ### BU 2
# ### Groups and memberships BU 2
# #######################################################################
# resource "google_cloud_identity_group" "business_unit_2" {
#   display_name         = "Business Unit Two"
#   description          = "Business Unit Two Group"
#   initial_group_config = "WITH_INITIAL_OWNER"

#   parent = "customers/${var.customer_id}"

#   group_key {
#       id = "business-unit-2@${var.domain}"
#   }

#   labels = {
#     "cloudidentity.googleapis.com/groups.discussion_forum" = ""
#   }
# }

# resource "google_cloud_identity_group_membership" "business_unit_2_membership_1" {
#   group    = google_cloud_identity_group.business_unit_2.id

#   preferred_member_key {
#     id = "dev1.bu2@${var.domain}"
#   }

#   roles {
#     name = "MEMBER"
#   }
# }

# resource "google_cloud_identity_group_membership" "business_unit_2_membership_2" {
#   group    = google_cloud_identity_group.business_unit_2.id

#   preferred_member_key {
#     id = "dev2.bu2@${var.domain}"
#   }

#   roles {
#     name = "MEMBER"
#   }
# }

# resource "google_cloud_identity_group_membership" "business_unit_2_membership_3" {
#   group    = google_cloud_identity_group.business_unit_2.id

#   preferred_member_key {
#     id = "cicd-test-bu2@${var.project_id}.iam.gserviceaccount.com"
#   }

#   roles {
#     name = "MEMBER"
#   }
# }

# #######################################################################
# ### Role assignment to groups with conditions BU 2
# #######################################################################
# resource "google_organization_iam_member" "business_unit_2_custom" {
#   org_id  = var.org_id
#   role    = "organizations/${var.org_id}/roles/CustomRoleApigeeXDeployDebug"
#   member  = "group:business-unit-2@${var.domain}"
# }

# resource "google_organization_iam_member" "business_unit_2_api_admin" {
#   org_id  = var.org_id
#   role    = "roles/apigee.apiAdminV2"
#   member  = "group:business-unit-2@${var.domain}"

#   condition {
#     title       = "business-unit-2"
#     description = "Conditions for business unit to edit bu2- prefixed proxies, shared flows and test"
#     expression  = "resource.name.startsWith('organizations/apigeex-exp/apis/bu2-') ||\nresource.name.startsWith('organizations/apigeex-exp/sharedflows/bu2-') ||\nresource.name.startsWith('organizations/apigeex-exp/apiproducts/bu2-') ||\n(resource.type == 'apigee.googleapis.com/Developer') ||\n(resource.type == 'apigee.googleapis.com/DeveloperApp' && resource.name.extract('/apps/{name}').startsWith('bu2-')) ||\nresource.type == 'cloudresourcemanager.googleapis.com/Project'"
#   }
# }

# resource "google_organization_iam_member" "business_unit_2_developer_admin" {
#   org_id  = var.org_id
#   role    = "roles/apigee.developerAdmin"
#   member  = "group:business-unit-2@${var.domain}"

#   condition {
#     title       = "business-unit-2"
#     description = "Conditions for business unit to edit bu2- prefixed proxies, shared flows and test"
#     expression  = "resource.name.startsWith('organizations/apigeex-exp/apis/bu2-') ||\nresource.name.startsWith('organizations/apigeex-exp/sharedflows/bu2-') ||\nresource.name.startsWith('organizations/apigeex-exp/apiproducts/bu2-') ||\n(resource.type == 'apigee.googleapis.com/Developer') ||\n(resource.type == 'apigee.googleapis.com/DeveloperApp' && resource.name.extract('/apps/{name}').startsWith('bu2-')) ||\nresource.type == 'cloudresourcemanager.googleapis.com/Project'"
#   }
# }

# #######################################################################
# ### Environment Access for BU 2
# #######################################################################
# resource "google_apigee_environment_iam_member" "member-bu2-test" {
#   org_id = "organizations/${var.project_id}"
#   env_id = "bu2-test"
#   role = "roles/apigee.environmentAdmin"
#   member = "group:business-unit-2@${var.domain}"
# }
