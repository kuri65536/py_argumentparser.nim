##[
## license
Copyright (c) 2022, shimoda as kuri65536 _dot_ hot mail _dot_ com
                      ( email address: convert _dot_ to . and joint string )

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.

## test matrix
test case                  | impl. | test num., etc
---------------------------|-------|-----------
options '='                | o | 4-1-1
]##
import unittest

import py_argumentparser

test "T4-1-1 can parse options include equals":
    var p = initArgumentParser()
    p.add_argument(' ', "vwx", default="")
    var (opts, vals) = p.parse_known_args(@["-a", "--vwx=1", "-c"])
    check vals == @["-a", "-c"]
    check opts.get_string("vwx") == "1"

