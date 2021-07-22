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

Build is done using Github actions. There are secrets defined for the actions to be able to push to radixdev and radixprod. These are the corresponding credentials for radix-cr-cicd-dev and radix-cr-cicd-prod service accounts

