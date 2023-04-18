/**
 * Copyright 2023 Nils Knieling
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

# IDENTITY POOL

output "pool_id" {
  description = "Identifier for the pool"
  value       = google_iam_workload_identity_pool.pool.id
}

output "pool_state" {
  description = "State of the pool"
  value       = google_iam_workload_identity_pool.pool.state
}

output "pool_name" {
  description = "Name for the pool"
  value       = google_iam_workload_identity_pool.pool.name
}

# IDENTITY POOL PROVIDER

output "provider_id" {
  description = "Identifier for the provider"
  value       = google_iam_workload_identity_pool_provider.provider.id
}

output "provider_state" {
  description = "State of the provider"
  value       = google_iam_workload_identity_pool_provider.provider.state
}

output "provider_name" {
  description = "The resource name of the provider"
  value       = google_iam_workload_identity_pool_provider.provider.name
}