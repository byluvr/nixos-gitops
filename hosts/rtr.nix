{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Загрузчик и системные параметры
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Включаем пересылку IP-пакетов
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Сетевая идентификация
  networking.hostName = "RTR";
  networking.useDHCP = false;

  # Настройка интерфейсов
  networking.interfaces = {
    # Внешний интерфейс (NAT)
    ens18 = {
      useDHCP = true;
    };
    
    # LAN segment
    ens19.ipv4.addresses = [{
      address = "192.168.10.1";
      prefixLength = 24;
    }];
  };

  # DNS
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Настройка NAT (Маскарадинг) для всех внутренних сетей
  networking.nat = {
    enable = true;
    externalInterface = "ens18";
    internalInterfaces = [ "ens19" ];
  };

  # Брандмауэр и безопасность
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    trustedInterfaces = [ "ens18" "ens19" ];
  };

  # 7. Локализация и пользователи
  time.timeZone = "Asia/Yekaterinburg";
  i18n.defaultLocale = "ru_RU.UTF-8";

  users.users.admin = {
    isNormalUser = true;
    description = "admin";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # 8. Системные пакеты
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    python3
    htop
    tcpdump
    tree
    iptables
    micro
  ];

  # 9. Настройка OpenSSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  system.stateVersion = "25.11";
}
