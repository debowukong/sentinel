resource "aws_efs_file_system" "foo" {
  creation_token = "my-efs-file-system"
  
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  
  tags = {
    Name = "MyEFSFileSystem"
  }
}

resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.foo.id
  
  posix_user {
    uid = 1000
    gid = 1000
  }
  
  root_directory {
    path = "/data"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }
}