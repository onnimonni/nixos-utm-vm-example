# Nixos VM to build x86_64 targets from Apple silicon
This guide is based on the great [nixos-utm](https://github.com/ciderale/nixos-utm) helper.

Before starting ensure you have [UTM](https://getutm.app/) installed with nix or homebrew.

## Installation on MacOS
`sed` is different in different platforms. Following steps only work on MacOS.
```sh
# Create new nix configuration for UTM vm
$ nix flake new -t github:ciderale/nixos-utm my-utm-vm

$ cd my-utm-vm

# Generate new passwordless ssh key to be used just for this VM
$ ssh-keygen -t ed25519 -f ~/.ssh/utm-vm-nixos-builder -P "" -C "$USER@utm-vm-nixos-builder"

# Replace the VM ssh key
$ sed -i'' -e "/ssh-ed25519/ s/.*/    \"$(cat ~/.ssh/utm-vm-nixos-builder.pub)\"/" configuration.nix

# Enable rosetta in the VM
$ sed -i '' '/services.openssh.enable = true;/i\
\ \ virtualisation.rosetta.enable = true;\
' configuration.nix

# Run the UTM installer
VM_NAME=nixos nix run github:ciderale/nixos-utm#nixosCreate .#utm
```

## .local address instead of 192.168.64.X ip-address
Avahi enables you want your host machine to find the VM with `utm-vm-nixos-builder.local` address.
You can enable it by adding following lines to the `configuration.nix`
```nix
{
  networking.hostName = "utm-vm-nixos-builder";

  services = {
      avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
          publish = {
              enable = true;
              userServices = true;
              addresses = true;
          };
      };
  };
}
```

## Local setup to your MacOS host
According to [this great guide](https://adrianhesketh.com/2024/04/20/setting-up-nixos-remote-builder-m1-mac/) nix will use `root` user for the remote builds and thus the root user needs to trust the builder VM.

It's probably easiest to just symlink your own ssh known hosts to the root user:

```sh
sudo mkdir /var/root/.ssh
sudo ln -s ~/.ssh/known_hosts /var/root/.ssh/
```

Then add the `x86_64-linux` capable remote builder to your nix config
```sh
mkdir -p ~/.config/nix/

echo -e "\nbuilders = ssh://root@utm-vm-nixos-builder.local?ssh-key=$HOME/.ssh/utm-vm-nixos-builder x86_64-linux" >> ~/.config/nix/nix.conf
```

After you have done all of this steps you should be able to use the remote builder in VM:
```sh
nix build --impure --expr '(with import <nixpkgs> { system = "x86_64-linux"; }; runCommand "foo" {} "uname > $out")'
cat result
```
If the file outputs `Linux` everything is working properly.

## Getting the IP address of the VM

```sh
VM_NAME=nixos nixos nix run github:ciderale/nixos-utm#nixosIP
```

## Logging to the nixos VM

```sh
ssh root@$(VM_NAME=nixos nix run github:ciderale/nixos-utm#nixosIP)
```

## Deploying new configuration for the VM
```sh
nix run nixpkgs#nixos-rebuild -- switch --fast --flake .#utm --target-host root@utm-vm-nixos-builder.local --build-host root@utm-vm-nixos-builder.local
```

## License
MIT