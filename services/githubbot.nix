{ nickname, password, room, secret, nginxVirtualHostDefaults }:
  {
    users.users.githubbot = {
      extraGroups = [ "keys" ];
      isSystemUser = true;
    };

    services.nginx = {
      enable = true;
      virtualHosts = nginxVirtualHostDefaults {
        "showdown.xfix.pw" = {
          forceSSL = true;
          root = ./githubbot;
          locations."/github".proxyPass = "http://127.0.0.1:3420";
        };
      };
    };

    systemd.services.githubbot = {
      wantedBy = [ "multi-user.target" ];
      after = [ "my-secret-key.service" ];
      wants = [ "my-secret-key.service" ];
      enable = true;
      environment = {
        npm_package_config_webhookport = "3420";
        npm_package_config_server = "sim.smogon.com";
        npm_package_config_serverport = "8000";
        npm_package_config_serverid = "showdown";
        npm_package_config_nickname = nickname;
        npm_package_config_room = room;
      };
      script = ''
        export npm_package_config_secret=$(cat /var/keys/githubbot-secret)
        export npm_package_config_password=$(cat /var/keys/githubbot-password)
        ${import ../packages/githubbot.nix}/bin/githubbot
      '';
      serviceConfig = {
        User = "githubbot";
        Restart = "always";
      };
    };

    deployment.keys.githubbot-secret = {
      destDir = "/var/keys";
      user = "githubbot";
      text = secret;
    };

    deployment.keys.githubbot-password = {
      destDir = "/var/keys";
      user = "githubbot";
      text = password;
    };
  }