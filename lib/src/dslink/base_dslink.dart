part of dsa.broker;

class BaseDsLink implements IRemoteRequester {

  String _dsId;

  String get dsId => _dsId;

  String _permissionGroup;

  String get permissionGroup => _permissionGroup;
}
