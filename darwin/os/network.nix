{ config, pkgs, ... }:

{
  # Use built-in networking options for static configuration
  networking = {
    knownNetworkServices = [ "Wi-Fi" "Thunderbolt Bridge" ];
    dns = [ "9.9.9.9" "149.112.112.112" "1.1.1.1" "8.8.8.8" ];
  };

  # Additional dynamic network settings through activation script
  system.activationScripts.networkSettings.text = ''
    # Find connected interface and service
    connected_interface=$(route -n get 0.0.0.0 2>/dev/null | awk '/interface: / {print $2}')
    connected_service=$(networksetup -listallhardwareports | grep -B1 "Device: ''${connected_interface}" | awk -F': ' '{print $2; exit}')
    all_services=$(networksetup -listallnetworkservices | sed '1d;s/^\*//g')

    # Deactivate unused services
    echo "$all_services" | grep -v "$connected_service" | \
      xargs -I {} sudo networksetup -setnetworkserviceenabled {} off

    # Show Time Connected in VPN menubar item
    defaults write com.apple.networkConnect VPNShowTime -bool false

    # Show Status When Connecting in VPN menubar item
    defaults write com.apple.networkConnect VPNShowStatus -bool false

    # Use Getflix then Google public DNS (uncomment if you want to override nix-darwin's dns settings)
    # sudo networksetup -setdnsservers "$connected_service" 103.241.150.100 54.251.190.247 8.8.8.8 8.8.4.4
  '';
}