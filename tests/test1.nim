##[
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
]##
import options
import tables
import unittest

import py_argumentparser

test "T1-1-1 can parse boolean options(short)":
    var p = initArgumentParser()
    p.add_argument('b', "", default=false)
    var (opts, vals) = p.parse_known_args(@["-a", "-b", "-c"])
    check vals == @["-a", "-c"]
    check opts.get_boolean("b", false) == true

    p.add_argument('a', "", default=false)
    (opts, vals) = p.parse_known_args(@["-a", "-b", "-c"])
    check vals == @["-c"]
    check opts.get_boolean("a", false) == true

test "T1-1-2 can parse boolean options(long)":
    var p = initArgumentParser()
    p.add_argument('\0', "bonus", default=false)
    var (opts, vals) = p.parse_known_args(@["--my", "--bonus", "--canceled"])
    check vals == @["--my", "--canceled"]
    check opts.get_boolean("bonus", false) == true

    p.add_argument('\0', "--my", default=false)
    (opts, vals) = p.parse_known_args(@["--my", "--bonus", "--canceled"])
    check vals == @["--canceled"]
    check opts.get_boolean("my", false) == true

    p.add_argument('\0', "--canceled", dest="not", default=false)
    (opts, vals) = p.parse_known_args(@["--my", "--bonus", "--canceled"])
    check len(vals) < 1
    check opts.get_boolean("not", false) == true

test "T1-2-1 can parse string options":
    var p = initArgumentParser()
    p.add_argument('\0', "test", default="abc")
    var (opts, vals) = p.parse_known_args(@["--no", "--test", "--no", "--life"])
    check vals == @["--no", "--life"]
    check opts.get_string("test") == "--no"

    (opts, vals) = p.parse_known_args(@["--life"])
    check vals == @["--life"]
    check opts.get_string("test") == "abc"

test "T1-2-2 can parse string from choices":
    var p = initArgumentParser()
    p.add_argument('\0', "no", default=none(string),
                   choices = @["air", "--test", "food"])
    var (opts, vals) = p.parse_known_args(@["--no", "--test"])
    check len(vals) < 1
    check opts.get_string("no") == "--test"

    # outside of choices
    (opts, vals) = p.parse_known_args(@["--no", "from choice"])
    check opts.get_string("no") == "air"

test "T1-3-1 can parse integer":
    var p = initArgumentParser()
    p.add_argument('\0', "this-num", default = -1)
    var (opts, vals) = p.parse_known_args(@["show", "--this-num", "123"])
    check vals == @["show"]
    check opts.get_integer("this-num", -2) == 123

    (opts, vals) = p.parse_known_args(@["no num were presented"])
    check opts.get_integer("this-num", -3) == -1

    p.add_argument('d', "no-default", default = none(int),
                   min = none(int), max = none(int))
    (opts, vals) = p.parse_known_args(@[])
    check opts.get_integer("no-default", -4) == -4

    p.add_argument('l', "limit", default = 1, min = 0, max = 10)
    try:
        (opts, vals) = p.parse_known_args(@["--limit", "-1"])
        assert false
    except:
        discard
    try:
        (opts, vals) = p.parse_known_args(@["--limit", "11"])
        assert false
    except:
        discard

test "T1-3-2 can parse combined opts":
    var p = initArgumentParser()
    p.add_argument('a', "", default=false)
    p.add_argument('r', "", default=true)
    p.add_argument('e', "", default = 0)
    var (opts, vals) = p.parse_known_args(@["10", "-are", "10", "?"])
    check vals == @["10", "?"]
    check opts.get_boolean("a", false) == true
    check opts.get_boolean("r", true) == false
    check opts.get_integer("e", -1) == 10

test "T1-4-1 can parse float":
    var p = initArgumentParser()
    p.add_argument('\0', "plus", default = 0.0)
    var (opts, vals) = p.parse_known_args(@["--plus", "1.1", "1.2"])
    check vals == @["1.2"]
    check opts.get_float("plus", -1.1) == 1.1

    (opts, vals) = p.parse_known_args(@[])
    check opts.get_float("plus", -1.2) == 0.0

    p.add_argument('m', "minus", default = none(float))
    (opts, vals) = p.parse_known_args(@["--minus", "2.2", "2.3"])
    check opts.get_float("minus", -3.3) == 2.2

    (opts, vals) = p.parse_known_args(@["--plus", "2.4", "2.5"])
    check opts.get_float("minus", -3.4) == -3.4

test "T2-1-1 parse_args":
    var p = initArgumentParser()
    p.add_argument('\0', "aaa", default = "aaa")
    var opts = p.parse_args(@["--aaa", "aab"])
    check opts.get_string("aaa") == "aab"

    try:
        discard p.parse_args(@["--plus", "2.4"])
        assert false
    except ValueError:
        discard

test "T2-1-2 actions":
    var ans: seq[string] = @[]

    proc t_1(key, val: string): ActionResult =
      {.gcsafe.}:
        ans.add(val)

    var p = initArgumentParser()
    p.add_argument('1', "", default = "a", action=t_1)
    p.add_argument('2', "", default = 1, action=t_1)
    p.add_argument('3', "", default = 1.0, action=t_1)
    p.add_argument('4', "", default = false, action=t_1)
    p.add_argument('5', "", action=t_1)
    var opts = p.parse_args(@["-1", "a",
                              "-2", "2", "-3", "1.1", "-4", "-5", "none"])
    check ans[0] == "a"
    check ans[1] == "2"
    check ans[2] == "1.1"
    check ans[3] == ""  # no-argument
    check ans[4] == "none"  # no-argument

    check opts.get_string("1") == "a"
    check opts.get_integer("2") == 1
    check opts.get_float("3") == 1.0
    check opts.get_boolean("4") == false


test "T2-2-1 string `$`":
    var p = initArgumentParser()
    p.add_argument('1', "", default = "a")
    p.add_argument('2', "", default = 1)
    p.add_argument('3', "", default = 1.0)
    p.add_argument('4', "", default = false)
    var opts = p.parse_args(@["-1", "a",
                              "-2", "2", "-3", "1.1", "-4"])
    check opts.get_string("1") == "a"
    check opts.get_integer("2", 0) == 2
    check opts.get_float("3", 1.2) == 1.1
    check opts.get_boolean("4", false) == true
    check $opts["1"] == "a"
    check $opts["2"] == "2"
    check $opts["3"] == "1.1"
    check $opts["4"] == "true"


# end of file {{{1
# vi: ft=nim:et:ts=4:fdm=marker:nowrap
