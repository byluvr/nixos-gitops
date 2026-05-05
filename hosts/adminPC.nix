{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # 1. Загрузчик
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # 2. Сетевая идентификация
  networking.hostName = "AdminPC";

  # 3. Настройка сети (Сегмент управления 192.168.30.0/24)
  networking = {
    useDHCP = false;
    networkmanager.enable = false; # Отключаем для стабильной статики

    interfaces = {
      # ПРОВЕРЬ имя (ens33/ens32) через 'ip a' перед применением
      ens18.ipv4.addresses = [{
        address = "192.168.10.40";
        prefixLength = 24;
      }];
    };

    # Шлюз — это внутренний адрес роутера в этой подсети
    defaultGateway = "192.168.10.1";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # 4. Локализация и время
  time.timeZone = "Asia/Yekaterinburg";
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # 5. Графическая оболочка (GNOME)
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb = {
    layout = "us,ru"; # Добавил русскую раскладку
    variant = "";
  };

  # 6. Звук и печать
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.github-runners.my-nixos-runner = {
  	enable = true;
  	url = "https://github.com/byluvr/nixos-gitops";
  	tokenFile = "/etc/nixos/github-token";
  	user = "admin";
  	extraPackages = with pkgs; [
  		ansible
  		git
  		python3
  		openssh
  		sshpass
  	];
  };
  
  # 7. Пользователь
  users.users.admin = {
    isNormalUser = true;
    description = "emil";
    extraGroups = [ "wheel" ]; # Убрали networkmanager
  };

  # 8. Системные пакеты (Инструменты администратора)
  environment.systemPackages = with pkgs; [
    # Твои пакеты
    micro
    firefox
    tree
    
    # Инструменты для диплома
    git
    ansible
    gh        # GitHub CLI
    sshpass   # Для автоматизации SSH по паролю
    htop
    tcpdump
    vim
    micro
    python3
  ];

  # 9. Настройка OpenSSH (то, что ты просил)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      X11Forwarding = true;
    };
  };

  system.stateVersion = "25.11";
}
