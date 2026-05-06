{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Загрузчик
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "cliPC";

  # Сетевые настройки
  networking.useDHCP = false;
  networking.interfaces.ens18.ipv4.addresses = [{
    address = "192.168.10.30";
    prefixLength = 24;
  }];

  # Шлюз
  networking.defaultGateway = "192.168.10.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Локализация
  time.timeZone = "Asia/Yekaterinburg";
  i18n.defaultLocale = "ru_RU.UTF-8";

  # Настройка графического интерфейса
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Настройка SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      X11Forwarding = true; 
    };
  };

  # Разрешаем SSH и HTTP
  networking.firewall.allowedTCPPorts = [ 22 80 ];

  # Пакеты для клиентской машины
  environment.systemPackages = with pkgs; [
    vim
    micro
    wget
    curl
    git
    python3
  ];

  system.stateVersion = "25.11";
}
