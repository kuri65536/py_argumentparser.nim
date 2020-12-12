#[
## license
Copyright (c) 2020, shimoda as kuri65536 _dot_ hot mail _dot_ com
                      ( email address: convert _dot_ to . and joint string )

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.

## test matrix
test case          | impl. | test num., etc
-------------------|-------|-----------
option common      |   |
  short-opt        | o | 1-1-1, with and without '-'
  no long-opt, dest-name  | o | 1-1-1, missing name
  combined short   |   |
  long-opt         | o | 1-1-2, with and without '--'
  no short-opt, dest-name | o | 1-1-2
  w/dest-name      | o | 1-1-2
  nargs            |   |
  action           |   |
  action w/default |   | not implemented, yet.
option boolean     |   |
  simple           | o | 1-1-1, 1-1-2
option string      | o | 1-2-1
  from defaults    | o | 1-2-1
  from choices     | o | 1-2-2
  outside choides  | o | 1-2-2
  as defaults      | o |
  dupplicated      | x |
option integer     | o | 1-3-1
  program defaults | o | 1-3-1
  default from get | o | 1-3-1
option float       | o | 1-4-1
  program defaults | o | 1-4-1
  default from get | o | 1-4-1
options merge      |   | see below
  record->range    | o | 3-1
]#
import unittest

import py_argumentparser

test "@T1-1-1 can parse boolean options(short)":
    var p = initArgumentParser()
    p.add_argument("b", "", default=false)
    var (opts, vals) = p.parse_known_args(@["-a", "-b", "-c"])
    check vals == @["-a", "-c"]
    check opts.get_boolean("b", false) == true

    p.add_argument("-a", "", default=false)
    (opts, vals) = p.parse_known_args(@["-a", "-b", "-c"])
    check vals == @["-c"]
    check opts.get_boolean("a", false) == true

test "@T1-1-2 can parse boolean options(long)":
    var p = initArgumentParser()
    p.add_argument("", "bonus", default=false)
    var (opts, vals) = p.parse_known_args(@["--my", "--bonus", "--canceled"])
    check vals == @["--my", "--canceled"]
    check opts.get_boolean("bonus", false) == true

    p.add_argument("", "--my", default=false)
    (opts, vals) = p.parse_known_args(@["--my", "--bonus", "--canceled"])
    check vals == @["--canceled"]
    check opts.get_boolean("my", false) == true

    p.add_argument("", "--canceled", dest="not", default=false)
    (opts, vals) = p.parse_known_args(@["--my", "--bonus", "--canceled"])
    check len(vals) < 1
    check opts.get_boolean("not", false) == true

test "@T1-2-1 can parse string options":
    var p = initArgumentParser()
    p.add_argument("", "test", default="abc")
    var (opts, vals) = p.parse_known_args(@["--no", "--test", "--no", "--life"])
    check vals == @["--no", "--life"]
    check opts.get_string("test", "") == "--no"

    (opts, vals) = p.parse_known_args(@["--life"])
    check vals == @["--life"]
    check opts.get_string("test", "") == "abc"

test "@T1-2-2 can parse string from choices":
    var p = initArgumentParser()
    p.add_argument("", "no", default="",
                   choices = @["air", "--test", "food"])
    var (opts, vals) = p.parse_known_args(@["--no", "--test"])
    check len(vals) < 1
    check opts.get_string("no", "") == "--test"

    # outside of choices
    (opts, vals) = p.parse_known_args(@["--no", "from choice"])
    check opts.get_string("no", "") == "air"

test "@T1-3-1 can parse integer":
    var p = initArgumentParser()
    p.add_argument("", "this-num", default = -1)
    var (opts, vals) = p.parse_known_args(@["show", "--this-num", "123"])
    check vals == @["show"]
    check opts.get_integer("this-num", -2) == 123

    (opts, vals) = p.parse_known_args(@["no num were presented"])
    check opts.get_integer("this-num", -3) == -1

    p.add_argument("d", "no-default", default = int_nil)
    (opts, vals) = p.parse_known_args(@[])
    check opts.get_integer("no-default", -4) == -4

test "@T1-4-1 can parse float":
    var p = initArgumentParser()
    p.add_argument("", "plus", default = 0.0)
    var (opts, vals) = p.parse_known_args(@["--plus", "1.1", "1.2"])
    check vals == @["1.2"]
    check opts.get_float("plus", -1.1) == 1.1

    (opts, vals) = p.parse_known_args(@[])
    check opts.get_float("plus", -1.2) == 0.0

    p.add_argument("m", "minus", default = int_nil)
    (opts, vals) = p.parse_known_args(@["--minus", "2.2", "2.3"])
    check opts.get_float("minus", -3.3) == 2.2

    (opts, vals) = p.parse_known_args(@["--plus", "2.4", "2.5"])
    check opts.get_float("minus", -3.4) == 3.4

# end of file {{{1
# vi: ft=nim:et:ts=4:fdm=marker:nowrap
