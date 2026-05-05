{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Загрузчик (стандарт для VMware)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "cliPC";

  # Сетевые настройки (Изолированная сеть через RTR)
  networking.useDHCP = false;
  networking.interfaces.ens18.ipv4.addresses = [{
    address = "192.168.10.30";
    prefixLength = 24;
  }];

  # Шлюзом выступает наш NixOS роутер
  networking.defaultGateway = "192.168.10.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Локализация (чтобы в браузере и консоли был русский язык)
  time.timeZone = "Asia/Yekaterinburg";
  i18n.defaultLocale = "ru_RU.UTF-8";

  # Настройка графического интерфейса (если планируешь использовать Firefox)
  # Если хочешь оставить только консоль, эти 3 строки можно закомментировать
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Настройка SSH (для управления с Windows 11 через Ansible)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
      X11Forwarding = true; # Позволит пробрасывать графические окна на твой Windows
    };
  };

  # Разрешаем SSH и HTTP (если вдруг захочешь что-то потестить) в файрволе
  networking.firewall.allowedTCPPorts = [ 22 80 ];

  # Пакеты для клиентской машины
  environment.systemPackages = with pkgs; [
    vim
    micro
    wget
    curl
    git
    python3
    htop
    tree
    tcpdump # Для анализа трафика между клиентом и сервером
  ];

  system.stateVersion = "25.11";
}
