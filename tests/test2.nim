##[
## license
Copyright (c) 2022, shimoda as kuri65536 _dot_ hot mail _dot_ com
                      ( email address: convert _dot_ to . and joint string )

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.

## test matrix
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
test case                  | impl. | test num., etc
---------------------------|-------|-----------
options '='                | o | 4-1-1
options by '-abc'          | o | 4-2-1
undefs by '-abc'           | o | 4-2-2
options w/arg by '-a'      | o | 4-2-4
wrong arg w/'-a'           | o | 4-2-3
missing arg w/'-a'         | o | 4-2-5
wrong by '-abc'            | o | 4-3-1, 4-3-2, 4-3-3
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


test "T4-2-2 invalid single character options":
    var p = initArgumentParser()
    p.add_argument('g', "g", default=false)
    p.add_argument('h', "h", default=false)
    p.add_argument('i', "i", default="")
    var (opts, vals) = p.parse_known_args(@["-a", "-def=1", "-c"])
    check vals == @["-a", "-def=1", "-c"]


test "T4-2-3 invalid single character options (w/o arg, just ignored)":
    var p = initArgumentParser()
    p.add_argument('g', "g", default=false)
    p.add_argument('h', "h", default=false)
    p.add_argument('i', "i", default="")
    var (opts, vals) = p.parse_known_args(@["-a", "-g=1", "-c"])
    check opts.get_boolean("g") == true
    check vals == @["-a", "-c"]


test "T4-2-4 single character options (w/arg)":
    var p = initArgumentParser()
    p.add_argument('g', "g", default=false)
    p.add_argument('h', "h", default=false)
    p.add_argument('i', "i", default="")
    var (opts, vals) = p.parse_known_args(@["-a", "-i", "-c"])
    check opts.get_boolean("g") == false
    check opts.get_boolean("h") == false
    check opts.get_string("i") == "-c"
    check vals == @["-a"]


test "T4-2-5 single character options (w/arg, missing)":
    var p = initArgumentParser()
    p.add_argument('g', "g", default=false)
    p.add_argument('h', "h", default=false)
    p.add_argument('i', "i", default="")
    var (opts, vals) = p.parse_known_args(@["-a", "-i"])
    check vals == @["-a"]


test "T4-3-1 invalid single character options (mixed)":
    var p = initArgumentParser()
    p.add_argument('g', "g", default=false)
    p.add_argument('h', "h", default=false)
    p.add_argument('i', "i", default="")
    var (opts, vals) = p.parse_known_args(@["-a", "-dhf=1", "-c"])
    check opts.get_boolean("h") == true
    check vals == @["-a", "-df=1", "-c"]


test "T4-3-2 invalid single character options (mixed-2)":
    var p = initArgumentParser()
    p.add_argument('g', "g", default=false)
    p.add_argument('h', "h", default=false)
    p.add_argument('i', "i", default="")
    var (opts, vals) = p.parse_known_args(@["-a", "-dhi=1", "-c"])
    check opts.get_boolean("h") == true
    check opts.get_string("i") == "1"
    check vals == @["-a", "-d", "-c"]


test "T4-3-3 invalid single character options (mixed-3)":
    var p = initArgumentParser()
    p.add_argument('g', "g", default=false)
    p.add_argument('h', "h", default=false)
    p.add_argument('i', "i", default="")
    var (opts, vals) = p.parse_known_args(@["-a", "-dih=0", "-c"])
    # =0 -> just ignored.
    check opts.get_boolean("h") == true
    check opts.get_string("i") == ""
    check vals == @["-a", "-di", "-c"]


# end of file {{{1
# vi: ft=nim:et:ts=4:fdm=marker:nowrap
