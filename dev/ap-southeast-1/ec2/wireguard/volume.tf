resource "aws_volume_attachment" "this" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.this.id
  instance_id = aws_instance.this[0].id
}

resource "aws_ebs_volume" "this" {
  availability_zone = "ap-southeast-1a"
  size              = 10
}