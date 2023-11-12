import 'package:mockito/mockito.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPermissionHandlerPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PermissionHandlerPlatform {
  final PermissionStatus permissionStatus;
  final ServiceStatus serviceStatus;

  MockPermissionHandlerPlatform(
      {this.permissionStatus = PermissionStatus.granted,
      this.serviceStatus = ServiceStatus.enabled});

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) =>
      Future.value(permissionStatus);

  @override
  Future<ServiceStatus> checkServiceStatus(Permission permission) =>
      Future.value(serviceStatus);

  @override
  Future<bool> openAppSettings() => Future.value(true);

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
      List<Permission> permissions) {
    var permissionsMap = <Permission, PermissionStatus>{
      Permission.camera: permissionStatus
    };
    return Future.value(permissionsMap);
  }

  @override
  Future<bool> shouldShowRequestPermissionRationale(Permission? permission) {
    return super.noSuchMethod(
      Invocation.method(
        #shouldShowPermissionRationale,
        [permission],
      ),
      returnValue: Future.value(true),
    );
  }
}
