part of dsa.broker;

final List<ConfigurationEntryProvision> _globalConfigurationSettings = [
  new ConfigurationEntryProvision(
    "route.provider",
    ConfigurationEntryType.string,
    defaultValue: "default",
    allowedValues: [
      "default"
    ]
  ),
  new ConfigurationEntryProvision(
    "storage.provider",
    ConfigurationEntryType.string,
    defaultValue: "json-directory",
    allowedValues: [
      "json-directory"
    ]
  ),
  new ConfigurationEntryProvision(
    "storage.json-directory.path",
    ConfigurationEntryType.string,
    defaultValue: "storage"
  ),
  new ConfigurationEntryProvision(
    "control.provider",
    ConfigurationEntryType.string,
    defaultValue: "default"
  ),
  new ConfigurationEntryProvision(
    "http.host",
    ConfigurationEntryType.string,
    defaultValue: "0.0.0.0"
  ),
  new ConfigurationEntryProvision(
    "http.port",
    ConfigurationEntryType.integer,
    defaultValue: 8085
  ),
  new ConfigurationEntryProvision(
    "logger.level",
    ConfigurationEntryType.string,
    defaultValue: "INFO",
    allowedValues: Level.LEVELS.map((l) => l.name).toList()
  ),
  new ConfigurationEntryProvision(
    "task_loop.interval",
    ConfigurationEntryType.integer,
    defaultValue: 1000,
    min: 1
  )
];
