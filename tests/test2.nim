##[
## license
Copyright (c) 2022, shimoda as kuri65536 _dot_ hot mail _dot_ com
                      ( email address: convert _dot_ to . and joint string )

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.

## test matrix
<<<<<<< HEAD
test case                  | impl. | test num., etc
---------------------------|-------|-----------
options '='                | o | 4-1-1
options by '-abc'          | o | 4-2-1
]##
import unittest

import py_argumentparser

test "T4-1-1 can parse options include equals":
    var p = initArgumentParser()
    p.add_argument(' ', "vwx", default="")
    var (opts, vals) = p.parse_known_args(@["-a", "--vwx=1", "-c"])
    check vals == @["-a", "-c"]
    check opts.get_string("vwx") == "1"


test "T4-2-1 can parse single character options":
    var p = initArgumentParser()
    p.add_argument('g', "g", default=false)
    p.add_argument('h', "h", default=false)
    p.add_argument('i', "i", default="")
    var (opts, vals) = p.parse_known_args(@["-a", "-ghi=1", "-c"])
    check vals == @["-a", "-c"]
    check opts.get_boolean("g") == true
    check opts.get_boolean("h") == true
    check opts.get_string("i") == "1"


# end of file {{{1
# vi: ft=nim:et:ts=4:fdm=marker:nowrap
