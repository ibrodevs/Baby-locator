#!/usr/bin/env python3
"""Check XML structure or the actual upload AAB, not a text match in sources."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
ANDROID = "{http://schemas.android.com/apk/res/android}"


def verify_manifest(xml):
    root = ET.fromstring(xml)
    if root.tag != "manifest":
        raise ValueError("Expected a <manifest> root")
    applications = root.findall("application")
    if len(applications) != 1:
        raise ValueError("Expected exactly one <application>")
    flags = [node for node in root.iter("meta-data")
             if node.get(ANDROID + "name") == "isMonitoringTool"]
    if len(flags) != 1 or flags[0] not in list(applications[0]):
        raise ValueError(
            "Declare exactly one isMonitoringTool <meta-data> directly inside "
            "<application>; root-level or component metadata is invalid"
        )
    flag = flags[0]
    if (flag.get(ANDROID + "value") != "child_monitoring"
            or ANDROID + "resource" in flag.attrib):
        raise ValueError("isMonitoringTool must use android:value=\"child_monitoring\" literally")
    return root


def java_tool(name):
    java_home = os.environ.get("JAVA_HOME")
    return str(Path(java_home) / "bin" / name) if java_home else name


def run(command):
    result = subprocess.run(command, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, check=True)
    return result.stdout


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--manifest", type=Path, help="Check an XML manifest only")
    mode.add_argument("--bundle", type=Path, help="Check the exact AAB to upload")
    parser.add_argument("--bundletool", type=Path, default=Path(os.environ.get(
        "BUNDLETOOL_JAR", ROOT / "build/tools/bundletool-all-1.18.3.jar")))
    parser.add_argument("--expected-package", default="com.company.familysecurity")
    parser.add_argument("--expected-version-code", type=int)
    parser.add_argument("--manifest-output", type=Path)
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    try:
        if args.manifest:
            verify_manifest(args.manifest.read_text())
            print(f"PASS: application metadata isMonitoringTool=child_monitoring: {args.manifest}")
            return 0

        if not args.bundle.is_file() or not args.bundletool.is_file():
            raise ValueError("AAB or bundletool JAR is missing; set --bundletool or BUNDLETOOL_JAR")
        tool = [java_tool("java"), "-jar", str(args.bundletool)]
        bundle = f"--bundle={args.bundle.resolve()}"
        run(tool + ["validate", bundle])
        xml = run(tool + ["dump", "manifest", bundle, "--module=base"])
        root = verify_manifest(xml)
        version = re.search(r"^version:\s*([^+\s]+)\+(\d+)\s*$",
                            (ROOT / "pubspec.yaml").read_text(), re.MULTILINE)
        if version is None:
            raise ValueError("Cannot read versionName+versionCode from pubspec.yaml")
        expected_code = (args.expected_version_code if args.expected_version_code is not None
                         else int(version[2]))
        expected = {"package": args.expected_package,
                    ANDROID + "versionCode": str(expected_code),
                    ANDROID + "versionName": version[1]}
        for key, value in expected.items():
            if root.get(key) != value:
                raise ValueError(f"Wrong {key}: expected {value!r}, found {root.get(key)!r}")
        if root.find("application").get(ANDROID + "debuggable", "false") != "false":
            raise ValueError("Upload bundle must not be debuggable")
        signature = run([java_tool("jarsigner"), "-J-Duser.language=en",
                         "-J-Duser.country=US", "-verify", str(args.bundle)])
        if "jar verified." not in signature or "unsigned entries" in signature:
            raise ValueError("AAB signature is missing or contains unsigned entries")
        digest = hashlib.sha256()
        with args.bundle.open("rb") as stream:
            for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                digest.update(chunk)
        report = {"artifact": str(args.bundle.resolve()),
                  "sha256": digest.hexdigest(),
                  "package": root.get("package"),
                  "versionCode": expected_code, "versionName": version[1],
                  "monitoringMetadataPath": "manifest/application/meta-data",
                  "isMonitoringTool": "child_monitoring",
                  "bundletoolValidation": "passed", "jarSignature": "verified"}
        for path, content in ((args.manifest_output, xml),
                              (args.report, json.dumps(report, indent=2) + "\n")):
            if path is not None:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content)
        print(json.dumps(report, indent=2))
        print("PASS: AAB metadata, identity, version and JAR signature verified. "
              "Active Play tracks still require verification in Play Console.")
        return 0
    except (OSError, ValueError, ET.ParseError, subprocess.CalledProcessError) as error:
        print(f"FAIL: {error}", file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError):
            print(error.stderr, file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
