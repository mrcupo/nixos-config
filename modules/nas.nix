{ ... }:

{
  boot.supportedFilesystems = [ "nfs" ];
  services.rpcbind.enable = true;

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
