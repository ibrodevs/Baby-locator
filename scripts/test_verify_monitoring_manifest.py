import unittest

from verify_monitoring_manifest import verify_manifest


FLAG = '<meta-data android:name="isMonitoringTool" android:value="child_monitoring" />'


def manifest(application="", outside=""):
    return ('<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
            f'{outside}<application>{application}</application></manifest>')


class MonitoringManifestTest(unittest.TestCase):
    def test_application_metadata_is_accepted(self):
        verify_manifest(manifest(FLAG))

    def test_v18_v19_root_level_regression_is_rejected(self):
        with self.assertRaises(ValueError):
            verify_manifest(manifest(outside=FLAG))

    def test_missing_flag_and_comment_are_rejected(self):
        for content in ("", f"<!-- {FLAG} -->"):
            with self.subTest(content=content), self.assertRaises(ValueError):
                verify_manifest(manifest(content))

    def test_component_metadata_is_rejected(self):
        with self.assertRaises(ValueError):
            verify_manifest(manifest(f"<activity>{FLAG}</activity>"))

    def test_duplicate_flag_is_rejected(self):
        for xml in (manifest(FLAG + FLAG), manifest(FLAG, outside=FLAG)):
            with self.subTest(xml=xml), self.assertRaises(ValueError):
                verify_manifest(xml)

    def test_wrong_name_type_or_value_is_rejected(self):
        for old, new in (("isMonitoringTool", "IsMonitoringTool"),
                         ("child_monitoring", "true"),
                         ("child_monitoring", "parental_control"),
                         ("child_monitoring", "@string/monitoring"),
                         ("android:value", "android:resource")):
            with self.subTest(new=new), self.assertRaises(ValueError):
                verify_manifest(manifest(FLAG.replace(old, new)))

    def test_unrelated_value_does_not_satisfy_flag(self):
        xml = manifest('<meta-data android:name="isMonitoringTool" android:value="other" />'
                       '<meta-data android:name="unrelated" android:value="child_monitoring" />')
        with self.assertRaises(ValueError):
            verify_manifest(xml)


if __name__ == "__main__":
    unittest.main()
