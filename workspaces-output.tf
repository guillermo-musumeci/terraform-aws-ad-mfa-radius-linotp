#######################################
## Amazon WorkSpaces Module - Output ##
#######################################

output "workspace_id" {
  value = aws_workspaces_workspace.workspaces.id
}

output "workspace_ip_address" {
  value = aws_workspaces_workspace.workspaces.ip_address
}

output "workspace_computer_name" {
  value = aws_workspaces_workspace.workspaces.computer_name
}

output "workspace_state" {
  value = aws_workspaces_workspace.workspaces.state
}
