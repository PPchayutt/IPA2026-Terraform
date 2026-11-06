# Fix Option 1: Ignore changes on the volatile tag in the instance lifecycle block (ใส่ไว้ใน resource "aws_instance" "server")
lifecycle {
  ignore_changes = [tags["LastPlanned"]]
}

# Fix Option 2 (Preferred / Shipped): Remove timestamp() from locals.tf entirely
locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "IPA-Student"
      # Deleted LastPlanned = timestamp()
    },
    var.extra_tags
  )
}
