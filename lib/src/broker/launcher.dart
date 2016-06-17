part of dsa.broker;

abstract class BrokerLauncherExtension {
  Future apply(BrokerLauncher launcher);
  Future modifyArgumentParser(ArgParser parser);
  Future modifyConfigurationProvision(ConfigurationProvision provision);
}

typedef Future<ConfigurationProvider> BrokerLauncherConfigProvider(ArgResults results);
typedef Future<ControlProvider> BrokerLauncherBasicProvider(ConfigurationProvider config);

class BrokerLauncher {
  final List<String> args;
  final List<BrokerLauncherExtension> extensions;

  final Map<String, BrokerLauncherConfigProvider> configurationProviders = {
    "json": (ArgResults results) async {
      var path = results["config-json-file"];
      return new JsonFileConfigurationProvider.forPath(path);
    }
  };

  final Map<String, BrokerLauncherBasicProvider> controlProviders = {
    "default": (ConfigurationProvider config) async => new DefaultControlProvider()
  };

  final Map<String, BrokerLauncherBasicProvider> storageProviders = {
    "json-directory": (ConfigurationProvider config) async {
      var path = await config.getString("storage.json-directory.path");
      return new JsonDirectoryStorageProvider.forPath(path);
    }
  };

  final Map<String, BrokerLauncherBasicProvider> routeProviders = {
    "default": (ConfigurationProvider config) async {
      return new DefaultRouteProvider();
    }
  };

  BrokerLauncher(this.args, this.extensions) {
    _configs.addAll(_globalConfigurationSettings);
  }

  List<ConfigurationEntryProvision> _configs = <ConfigurationEntryProvision>[];

  Future<Broker> launch() async {
    for (BrokerLauncherExtension extension in extensions) {
      await extension.apply(this);
    }

    var argp = new ArgParser(allowTrailingOptions: true);
    argp.addOption("config-provider", help: "Configuration Provider", allowed: [
      "json"
    ], defaultsTo: "json");

    argp.addOption(
      "config-json-file",
      help: "JSON Configuration File",
      defaultsTo: "broker.json"
    );

    for (BrokerLauncherExtension extension in extensions) {
      await extension.modifyArgumentParser(argp);
    }

    var results = argp.parse(args);
    var config = await createConfigurationProvider(results);
    var provision = new ConfigurationProvision(_configs);
    for (BrokerLauncherExtension extension in extensions) {
      await extension.modifyConfigurationProvision(provision);
    }
    await config.provision(provision);

    for (BrokerLauncherExtension extension in extensions) {
      await extension.modifyArgumentParser(argp);
    }

    var control = await createControlProvider(config);
    var storage = await createStorageProvider(config);
    var route = await createRouteProvider(config);
    var logger = await createLogger(config);

    var broker = new Broker(
      control,
      config,
      storage,
      route,
      logger
    );

    await broker.init();
    await broker.setupHttpServer(
      host: await config.getString("http.host"),
      port: await config.getInteger("http.port")
    );
    return broker;
  }

  Future<ControlProvider> createControlProvider(ConfigurationProvider config) async {
    var type = await config.getString("control.provider");

    ControlProvider provider;

    if (controlProviders.containsKey(type)) {
      var builder = controlProviders[type];
      provider = await builder(config);
    } else {
      throw new ConfigurationException(
        "Invalid control provider: ${type}"
      );
    }

    return provider;
  }

  Future<StorageProvider> createStorageProvider(ConfigurationProvider config) async {
    var type = await config.getString("storage.provider");

    StorageProvider provider;

    if (storageProviders.containsKey(type)) {
      var builder = storageProviders[type];
      provider = await builder(config);
    } else {
      throw new ConfigurationException(
        "Invalid storage provider: ${type}"
      );
    }

    return provider;
  }

  Future<Logger> createLogger(ConfigurationProvider config) async {
    var level = await config.getString("logger.level");
    level = level.toLowerCase();

    hierarchicalLoggingEnabled = true;
    var logger = new Logger("DSA");
    logger.level = Level.LEVELS.firstWhere(
      (l) => l.name.toLowerCase() == level, orElse: () {
        return Level.INFO;
    });

    logger.onRecord.listen((LogRecord record) {
      print("[${record.level.name}] ${record.message}");
      if (record.error != null) {
        print(record.error);
      }

      if (record.stackTrace != null) {
        print(record.stackTrace);
      }
    });

    return logger;
  }

  Future<RouteProvider> createRouteProvider(ConfigurationProvider config) async {
    var type = await config.getString("route.provider");

    RouteProvider provider;

    if (routeProviders.containsKey(type)) {
      var builder = routeProviders[type];
      provider = await builder(config);
    } else {
      throw new ConfigurationException(
        "Invalid route provider: ${type}"
      );
    }

    return provider;
  }

  Future<ConfigurationProvider> createConfigurationProvider(ArgResults results) async {
    var type = results["config-provider"];

    ConfigurationProvider provider;

    if (configurationProviders.containsKey(type)) {
      var builder = configurationProviders[type];
      provider = await builder(results);
    } else {
      throw new ConfigurationException(
        "Invalid configuration provider: ${type}"
      );
    }

    return provider;
  }
}
