yet another option parser like python api.
===============================================================================
yet another options parser to be able to replace python api.

- python like api, not compatible with nim's parseopt.
- but strict type checking with nim language.



How to use
-----------------------------------------
use from nimble::

```shell
$ nimble install https://github.com/kuri65536/py_argumentparser.nim
```

from git::

```shell
$ git clone install https://github.com/kuri65536/py_argumentparser.nim py_argumentparser
$ cat > test.nim <<EOF
import py_argumentparser
var parser = initArgumentParser()
parser.add_argument('t', "test", default = "is ng")
var opts = parser.parse_args()
echo "test: " & opts.get_string("test")
EOF
$ nim c -r test.nim --test "is ok"
test: is ok
```


Requirements
-----------------------
- nim (>= 0.19.4)


Implement status
-----------------------------------------

argument              | impl. | memo
----------------------|---|-----
string                | o |
multiple strings      | x |
boolean               | o |
integer               | o |
float                 | o |
arguments             | x |


<!--
### method

method / property       | impl. | memo
--------------------------|-----|------
`BOOLEAN_STATES`          | o   | ...
`MAX_INTERPOLATION_DEPTH` | o   | ...
`optionxform(option)`     | o   | affects on every read, get, or set operation.
`SECTCRE`                 |     | no-plan to implement. (hard coded in this module)
`defaults()`              | o   | ...
`sections()`              | o   | ...



### Exceptions

Exceptions                  | impl. | memo
--------------------------------|---|-------
Error                           | o | base of exceptions in this module.
NoSectionError                  | o | ...
-->


Development Environment
-----------------------------------------

| term | description   |
|:----:|:--------------|
| OS   | Debian on Android 10 |
| lang | nim 0.19.4 in Debian bundled |




License
------------
see the top of source code, it is MPL2.0.


Samples
-----------------------------------------
see tests folder.


Release
-----------------------------------------
| version | description |
|:-------:|:------------|
| 0.2.0   | change some API for more type strictly |
| 0.1.0   | 1st version |


Donations
---------------------
If you are feel to nice for this software, please donate to

[![img-bitcoin]][lnk-bitcoin]
&nbsp;&nbsp;or&nbsp;&nbsp;
[![img-etherium]][lnk-bitcoin]

- [bitcoin:39Qx9Nffad7UZVbcLpVpVanvdZEQUanEXd][lnk-bitcoin]
- [ethereum:0x9d03b1a8264023c3ad8090b8fc2b75b1ba2b3f0f][lnk-bitcoin]
- or [liberapay](https://liberapay.com/kuri65536) .

[lnk-bitcoin]:  https://kuri65536.bitbucket.io/donation.html?message=thank-for-py_argumentparser
[img-bitcoin]:  https://github.com/user-attachments/assets/abce4347-bcb3-42c6-a9e8-1cd12f1bd4a5
[img-etherium]: https://github.com/user-attachments/assets/d1bdb9a8-9c6f-4e74-bc19-0d0bfa041eb2

