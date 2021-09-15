# radix-image-scanner

[![Build Status](https://github.com/equinor/radix-image-scanner/workflows/radix-image-scanner-build/badge.svg)](https://github.com/equinor/radix-image-scanner/actions?query=workflow%3Aradix-image-scanner-build)

The radix-image-scanner gives radix-pipeline access to security scan the images produced during build.

The result of the scan is written to a k8s ConfigMap
1. An aggregated vulnerability count per severity, written to a key defined by VULNERABILITY_COUNT_KEY as a key/value JSON document where key is severity in lowercase and value is number of vulnerabilities.
2. A detailed list of all vulnerabilities, written to a key defined by VULNERABILITY_LIST_KEY as a JSON document. Ref JSON format below.

JSON for aggregated count: 
```
    {
        "severity1": 2,
        "severity2": 10,
        "severity3": 14,
        ...
    }
```

JSON for detailed list of vulnerabilities:
```
[
    {
        "packageName": "coreutils",
        "version": "8.30-3",
        "target": "radixdev.azurecr.io/radix-job-demo-api:cz413 (debian 10.10)",
        "title": "coreutils: Non-privileged session can escape to the parent session in chroot",
        "description": "chroot in GNU coreutils...",
        "severity": "LOW",
        "publishedDate": "2017-02-07T15:59:00Z",
        "cwe": [
          "CWE-20"
        ],
        "cve": [
          "CVE-2016-2781"
        ],
        "cvss": 6.5,
        "references": [
          "http://seclists.org/oss-sec/2016/q1/452",
          "http://www.openwall.com/lists/oss-security/2016/02/28/2",
          "http://www.openwall.com/lists/oss-security/2016/02/28/3",
          "https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-2781",
          "https://lists.apache.org/thread.html/rf9fa47ab66495c78bb4120b0754dd9531ca2ff0430f6685ac9b07772@%3Cdev.mina.apache.org%3E",
          "https://lore.kernel.org/patchwork/patch/793178/"
        ]
    },
    {...}
]
```

## Parsing description output from SNYK cli

The original description output from SNYK contains a lot of unneccessary text that we want to remove before storing the final results. 

Below are the two original description formats we have seens as output from SNYK. Typically we only want the actual description, e.g. "A flaw was found in libwebp...". Both outputs has a header "## NVD Description", a "Versions mentioned..." and a "## References" section. The first example also has a "See \`Remediation\` section".

We test for both these patterns using regex. On match, we use the captured text describing the actual vulnerability, and on no match we use the original description.

```
## NVD Description\n<i> **Note:** </i>\n<i> Versions mentioned in the description apply to the upstream `libwebp` package. </i>\n<i> See `Remediation` section below for `Debian:10` relevant versions. </i>\n\nA flaw was found in libwebp in versions before 1.0.1. An out-of-bounds read was found in function ApplyFilter. The highest threat from this vulnerability is to data confidentiality and to the service availability.\n## Remediation\nUpgrade `Debian:10` `libwebp` to version 0.6.1-2+deb10u1 or higher.\n## References\n- [ADVISORY](https://security-tracker.debian.org/tracker/CVE-2018-25010)\n- [CONFIRM](https://support.apple.com/kb/HT212601)\n- [DEBIAN](https://www.debian.org/security/2021/dsa-4930)\n- [MISC](https://bugzilla.redhat.com/show_bug.cgi?id=1956918)\n- [MLIST](https://lists.debian.org/debian-lts-announce/2021/06/msg00005.html)\n- [MLIST](https://lists.debian.org/debian-lts-announce/2021/06/msg00006.html)\n
```

```
## NVD Description\n<i> **Note:** </i>\n<i> Versions mentioned in the description apply to the upstream `libwebp` package. </i>\n\nMultiple integer overflows in libwebp allows attackers to have unspecified impact via unknown vectors.\n## Remediation\nThere is no fixed version for `Debian:10` `libwebp`.\n## References\n- [CONFIRM](https://chromium.googlesource.com/webm/libwebp/+/e2affacc35f1df6cc3b1a9fa0ceff5ce2d0cce83)\n- [Debian Security Tracker](https://security-tracker.debian.org/tracker/CVE-2016-9085)\n- [Fedora Security Update](https://lists.fedoraproject.org/archives/list/package-announce@lists.fedoraproject.org/message/LG5Q42J7EJDKQKWTTHCO4YZMOMP74YPQ/)\n- [Fedora Security Update](https://lists.fedoraproject.org/archives/list/package-announce@lists.fedoraproject.org/message/PTR2ZW67TMT7KC24RBENIF25KWUJ7VPD/)\n- [Fedora Security Update](https://lists.fedoraproject.org/archives/list/package-announce@lists.fedoraproject.org/message/SH6X3MWD5AHZC5JT4625PGFHAYLR7YW7/)\n- [Gentoo Security Advisory](https://security.gentoo.org/glsa/201701-61)\n- [MLIST](https://lists.apache.org/thread.html/rf9fa47ab66495c78bb4120b0754dd9531ca2ff0430f6685ac9b07772@%3Cdev.mina.apache.org%3E)\n- [OSS security Advisory](http://www.openwall.com/lists/oss-security/2016/10/27/3)\n- [RedHat Bugzilla Bug](https://bugzilla.redhat.com/show_bug.cgi?id=1389338)\n- [Security Focus](http://www.securityfocus.com/bid/93928)\n- [Ubuntu CVE Tracker](http://people.ubuntu.com/~ubuntu-security/cve/CVE-2016-9085)\n
```

Build is done using Github actions. There are secrets defined for the actions to be able to push to radixdev and radixprod. These are the corresponding credentials for radix-cr-cicd-dev and radix-cr-cicd-prod service accounts

