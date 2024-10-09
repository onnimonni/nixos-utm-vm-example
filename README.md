# Steps
Start the utm UTM VM
```
# Create new nix configuration for UTM vm
$ nix flake new -t github:ciderale/nixos-utm my-utm-vm

$ cd my-utm-vm
# Replace the ssh key with the key that comes first from your ssh-agent
$ sed -i'' -e "/ssh-ed25519/ s/.*/    \"$(ssh-add -L | head -n1)\"/" configuration.nix

# Run the UTM installer
export VM_NAME=nixos
nix run github:ciderale/nixos-utm#nixosCreate .#utm
```