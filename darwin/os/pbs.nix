{ config, pkgs, ... }:

{
  # Services Menu Agent settings through activation script
  system.activationScripts.servicesMenuSettings.text = ''
    # Add Terminal service "New Terminal at Folder" to the Services Menu
    defaults write pbs NSServicesStatus -dict-add '"com.apple.Terminal - New Terminal at Folder - newTerminalAtFolder"' '{
      "enabled_context_menu" = 1;
      "enabled_services_menu" = 1;
    }'
    
    # Flush the services cache to apply changes
    /System/Library/CoreServices/pbs -flush
  '';
}