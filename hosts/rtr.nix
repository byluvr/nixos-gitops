{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # 1. Загрузчик и системные параметры
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Включаем пересылку IP-пакетов для работы маршрутизации между подсетями
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # 2. Сетевая идентификация
  networking.hostName = "RTR";
  networking.useDHCP = false;

  # 3. Настройка интерфейсов для сегментированной топологии
  networking.interfaces = {
    # Внешний интерфейс (VMware NAT)
    ens18 = {
      useDHCP = true;
    };
    
    # Сегмент Серверов (SRV)
    ens19.ipv4.addresses = [{
      address = "192.168.10.1";
      prefixLength = 24;
    }];
  };

  # 4. Маршрутизация и DNS
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # 5. Настройка NAT (Маскарадинг) для всех внутренних сетей
  networking.nat = {
    enable = true;
    externalInterface = "ens18";
    internalInterfaces = [ "ens19" ];
  };

  # 6. Брандмауэр и безопасность
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # Порт для управления по SSH
    # Доверяем трафику между нашими внутренними интерфейсами
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

  # 8. Системные пакеты (Полный набор для администрирования)
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    python3
    htop
    tcpdump   # Незаменим для диплома при анализе прохождения трафика
    tree
    iptables  # Для просмотра правил NAT напрямую
    micro
  ];

  # 9. Настройка OpenSSH сервера
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  system.stateVersion = "25.11";
}
