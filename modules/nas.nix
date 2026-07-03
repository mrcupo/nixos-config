{ ... }:

# Synology DS at 192.0.2.10 — NFS client mount for the "PC Games" share.
# Used to copy game installers/folders to the local SSDs as needed; not for
# launching games directly off the network.
#
# Synology side (one-time, via DSM):
#   1. Control Panel → File Services → NFS → enable (NFSv4.1).
#   2. Control Panel → Shared Folder → "PC Games" → Edit → NFS Permissions:
#        Hostname/IP : 192.0.2.0/24   (or this machine's IP)
#        Privilege   : Read/Write
#        Squash      : Map all users to admin
#        Security    : sys
#        Async, allow non-privileged ports : on
#   3. Note the mount path DSM displays (e.g. /volume1/PC Games) and update
#      `device` below if the volume number differs.

{
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

  # Automount on first access, unmount after 10 min idle so the NAS can sleep.
  fileSystems."/mnt/nas-games" = {
    device = "192.0.2.10:/volume1/example-share";
    fsType = "nfs";
    options = [
      "nfsvers=4.1"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "x-systemd.mount-timeout=10"
      "soft"
      "timeo=30"
      "retrans=2"
      "_netdev"
    ];
  };
}
