import 'package:flutter_test/flutter_test.dart';
import 'package:fusage/context/settings.dart';

import 'package:fusage/extra/enums.dart';
import 'package:fusage/extra/load_file_data.dart';

void main() {
  test('Save/Load Backup Settings', () async {
    SettingDataType settingsData = SettingDataType.init(MetricTypeEnum.metric, 'EUR', SummaryTimeRangeEnum.total);
    CreateBackupDataResult backupData = await createBackupData('./test_resources', [], settingsData);

    expect(backupData.success, true);

    var loadedData = await loadBackupData('./test_resources/${backupData.fileName}');

    expect(loadedData['settings']['currencyType'], 'EUR');
    expect(loadedData['vehicles'], []);
  });
}