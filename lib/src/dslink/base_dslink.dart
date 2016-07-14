part of dsa.broker;

class BaseDsLink implements IRemoteRequester {

  // dsId or user name
  String _dsId;

  String get dsId => _dsId;

  String _permissionGroup;

  String get permissionGroup => _permissionGroup;
}
