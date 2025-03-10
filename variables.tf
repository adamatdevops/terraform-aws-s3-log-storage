variable "bucket_name" {
  type        = string
  description = <<-EOT
    Bucket name. If provided, the bucket will be created with this name
    instead of generating the name from the context.
    EOT
  default     = ""
  nullable    = false
}

variable "object_lock_configuration" {
  type = object({
    mode  = string # Valid values are GOVERNANCE and COMPLIANCE.
    days  = number
    years = number
  })
  default     = null
  description = "A configuration for S3 object locking. With S3 Object Lock, you can store objects using a `write once, read many` (WORM) model. Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely."
}

variable "acl" {
  type        = string
  description = "The canned ACL to apply. We recommend log-delivery-write for compatibility with AWS services"
  default     = "log-delivery-write"
  nullable    = false
}

variable "source_policy_documents" {
  type        = list(string)
  description = <<-EOT
    List of IAM policy documents that are merged together into the exported document.
    Statements defined in source_policy_documents must have unique SIDs.
    Statement having SIDs that match policy SIDs generated by this module will override them.
    EOT
  default     = []
  nullable    = false
}

variable "s3_object_ownership" {
  type        = string
  description = "Specifies the S3 object ownership control. Valid values are `ObjectWriter`, `BucketOwnerPreferred`, and 'BucketOwnerEnforced'."
  default     = "BucketOwnerPreferred"
  nullable    = false
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = <<-EOT
    When `true`, permits a non-empty S3 bucket to be deleted by first deleting all objects in the bucket.
    THESE OBJECTS ARE NOT RECOVERABLE even if they were versioned and stored in Glacier.
    Must be set `false` unless `force_destroy_enabled` is also `true`.
    EOT
  nullable    = false
}

variable "versioning_enabled" {
  type        = bool
  description = "Enable object versioning, keeping multiple variants of an object in the same bucket"
  default     = true
  nullable    = false
}

variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "The server-side encryption algorithm to use. Valid values are AES256 and aws:kms"
  nullable    = false
}

variable "kms_master_key_arn" {
  type        = string
  default     = ""
  description = "The AWS KMS master key ARN used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms"
  nullable    = false
}

variable "bucket_key_enabled" {
  type        = bool
  description = <<-EOT
  Set this to true to use Amazon S3 Bucket Keys for SSE-KMS, which reduce the cost of AWS KMS requests.

  For more information, see: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
  EOT
  default     = false
  nullable    = false
}

variable "block_public_acls" {
  type        = bool
  description = "Set to `false` to disable the blocking of new public access lists on the bucket"
  default     = true
  nullable    = false
}

variable "block_public_policy" {
  type        = bool
  description = "Set to `false` to disable the blocking of new public policies on the bucket"
  default     = true
  nullable    = false
}

variable "ignore_public_acls" {
  type        = bool
  description = "Set to `false` to disable the ignoring of public access lists on the bucket"
  default     = true
  nullable    = false
}

variable "restrict_public_buckets" {
  type        = bool
  description = "Set to `false` to disable the restricting of making the bucket public"
  default     = true
  nullable    = false
}

variable "access_log_bucket_name" {
  type        = string
  description = "Name of the S3 bucket where S3 access logs will be sent to"
  default     = ""
  nullable    = false
}

variable "access_log_bucket_prefix" {
  type        = string
  description = "Prefix to prepend to the current S3 bucket name, where S3 access logs will be sent to"
  default     = "logs/"
  nullable    = false
}

variable "allow_encrypted_uploads_only" {
  type        = bool
  description = "Set to `true` to prevent uploads of unencrypted objects to S3 bucket"
  default     = false
  nullable    = false
}

variable "allow_ssl_requests_only" {
  type        = bool
  description = "Set to `true` to require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests"
  default     = true
  nullable    = false
}

variable "bucket_notifications_enabled" {
  type        = bool
  description = "Send notifications for the object created events. Used for 3rd-party log collection from a bucket"
  default     = false
  nullable    = false
}

variable "bucket_notifications_type" {
  type        = string
  description = "Type of the notification configuration. Only SQS is supported."
  default     = "SQS"
  nullable    = false
}

variable "bucket_notifications_prefix" {
  type        = string
  description = "Prefix filter. Used to manage object notifications"
  default     = ""
  nullable    = false
}

variable "lifecycle_configuration_rules" {
  type = list(object({
    enabled = bool
    id      = string

    abort_incomplete_multipart_upload_days = number

    # `filter_and` is the `and` configuration block inside the `filter` configuration.
    # This is the only place you should specify a prefix.
    filter_and = any
    expiration = any
    transition = list(any)

    noncurrent_version_expiration = any
    noncurrent_version_transition = list(any)
  }))
  description = <<-EOT
    A list of S3 bucket v2 lifecycle rules, as specified in [terraform-aws-s3-bucket](https://github.com/cloudposse/terraform-aws-s3-bucket)"
    These rules are not affected by the deprecated `lifecycle_rule_enabled` flag.
    **NOTE:** Unless you also set `lifecycle_rule_enabled = false` you will also get the default deprecated rules set on your bucket.
    EOT
  default     = []
  nullable    = false
}
