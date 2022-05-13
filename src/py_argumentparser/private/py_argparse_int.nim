##[
py_argparse_int.nim
---------------------------

license
-----------
Copyright (c) 2020, shimoda as kuri65536 _dot_ hot mail _dot_ com
                      ( email address: convert _dot_ to . and joint string )

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.
]##
import options
import strformat
import strutils
import tables

import py_argparse_common


type  # {{{1
  OptionsActionInteger* = ref object of OptionsAction  # {{{1
    default, min, max: Option[int]

  OptionInteger* = ref object of OptionBase  # {{{1
    val: int


proc to_string*(self: OptionInteger): string =  # {{{1
    return $self.val


proc add_argument*(self: ArgumentParser,  # int {{{1
                   opt_short: char, opt_long: string,
                   default, min, max: Option[int], dest = "",
                   action: ActionFunc = nil, help_text = ""): void =
    var act = OptionsActionInteger(default: default,
                                   min: min, max: max,
                               action: action, help_text: help_text)
    OptionsAction(act).set_opt_name(opt_short, opt_long, dest)
    self.actions.add(act)


proc add_argument*(self: ArgumentParser,  # int {{{1
                   opt_short: char, opt_long: string,
                   default, min, max: int, dest = "",
                   action: ActionFunc = nil, help_text = ""): void =
    ##[add a integer argument to parser with limits.
    ]##
    add_argument(self, opt_short, opt_long, some(default),
                 some(min), some(max), dest,
                 action, help_text)


proc add_argument*(self: ArgumentParser,  # int {{{1
                   opt_short: char, opt_long: string, default: int,
                   dest = "", range = range[low(int)..high(int)],
                   action: ActionFunc = nil, help_text = ""): void =
    ##[add a integer argument to parser without limits.
    ]##
    add_argument(self, opt_short, opt_long, some(default),
                 none(int), none(int), dest,
                 action, help_text)


method action_default(act: OptionsActionInteger, opts: var Options,  # {{{1
                      key, val: string): void =
    let v = parseInt(val)
    if act.max.isSome and v > act.max.get():
        raise newException(ValueError,
                           act.dest_name & " over limit: " & $v)
    if act.min.isSome and v < act.min.get():
        raise newException(ValueError,
                           act.dest_name & " under limit: " & $v)
    opts[key] = OptionInteger(val: v)


method set_default*(self: OptionsActionInteger, opts: var Options): void =
    if self.default.isNone:
        return
    opts[self.dest_name] = OptionInteger(val: self.default.get())


proc get_integer*(self: Options, name: string, default: Option[int]  # {{{1
                  ): int =
    if self.hasKey(name):
        var tmp = OptionInteger(self[name])
        return tmp.val
    if default.isSome:
        return default.get()
    raise newException(KeyError,
                       fmt"{name} has no-default and not specified.")


proc get_integer*(self: Options, name: string, default: int): int =  # {{{1
    return self.get_integer(name, some(default))


proc get_integer*(self: Options, name: string): int =  # {{{1
    ## see `get_string`
    return self.get_integer(name, none(int))


# end of file {{{1
# vi: ft=nim:et:ts=4:fdm=marker:nowrap
