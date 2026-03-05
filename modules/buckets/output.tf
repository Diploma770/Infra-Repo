output "bucket_names" {
  value = concat(
    keys(google_storage_bucket.buckets),
    keys(google_storage_bucket.protected_buckets)
  )
}
