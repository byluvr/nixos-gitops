{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Загрузчик (стандарт для VMware/BIOS)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "SRV"; 

  # Настройка сети
  networking.useDHCP = false;
  networking.interfaces.ens33.ipv4.addresses = [{
    address = "192.168.10.20"; # Статический IP сервера
    prefixLength = 24;
  }];

  # Указываем наш RTR как основной шлюз
  networking.defaultGateway = "192.168.10.1";
  
  # Используем внешние DNS через шлюз
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Настройка SSH для управления через Ansible и GitHub Actions
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes"; # Нужно для начальной настройки Ansible
      PasswordAuthentication = true;
    };
  };

  # Открываем порты: 22 (SSH) и 80 (будущий веб-сервер для демо)
  networking.firewall.allowedTCPPorts = [ 22 80 ];

  # Системный софт для сервера
  environment.systemPackages = with pkgs; [
    vim
    python3
    wget
    curl
    git
    htop
    nettools
    fastfetch
    micro # Команды типа netstat
  ];

  # Для демонстрации в дипломе добавим простой сервис Nginx
  # Это покажет, что конфигурация применилась успешно
  services.nginx = {
    enable = true;
    virtualHosts."localhost" = {
      addSSL = false;
      default = true;
      root = "/var/www/html";
    };
  };

  # Создаем тестовую страницу
  systemd.tmpfiles.rules = [
    "d /var/www/html 0755 nginx nginx -"
    "f /var/www/html/index.html 0644 nginx nginx - <h1>NixOS GitOps Demo: SRV is Online</h1>"
  ];

  system.stateVersion = "25.11"; 
}
