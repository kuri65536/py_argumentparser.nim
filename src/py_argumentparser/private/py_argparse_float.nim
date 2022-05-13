##[
py_argparse_float.nim
---------------------------

license
-----------
Copyright (c) 2022, 2020, shimoda as kuri65536 _dot_ hot mail _dot_ com
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
  OptionsActionFloat* = ref object of OptionsAction  # {{{1
    default: Option[float]

  OptionFloat* = ref object of OptionBase  # {{{1
    val: float


proc to_string*(self: OptionFloat): string =  # {{{1
    return $self.val


proc add_argument*(self: ArgumentParser,  # float {{{1
                   opt_short: char, opt_long: string, default: Option[float],
                   dest = "", action: ActionFunc = nil, help_text = ""): void =
    var act = OptionsActionFloat(
            default: default,
            action: action, help_text: help_text)
    OptionsAction(act).set_opt_name(opt_short, opt_long, dest)
    self.actions.add(act)

    if not isNil(action):
        act.action = action


proc add_argument*(self: ArgumentParser,  # float {{{1
                   opt_short: char, opt_long: string, default: float,
                   dest = "",
                   action: ActionFunc = nil, help_text = ""): void =
    ## add a string argument to parser.
    add_argument(self, opt_short, opt_long, some(default), dest,
                 action, help_text)


method set_default(self: OptionsActionFloat, opts: var Options): void =  # {{{1
    if self.default.isNone:
        return
    opts[self.dest_name] = OptionFloat(val: self.default.get())


method action_default(act: OptionsActionFloat, opts: var Options,  # {{{1
                      key, val: string): void =
    opts[key] = OptionFloat(val: parseFloat(val))


proc get_float*(self: Options, name: string, default: Option[float]  # {{{1
                ): float =
    if self.hasKey(name):
        var tmp = OptionFloat(self[name])
        return tmp.val
    if default.isSome:
        return default.get()
    raise newException(KeyError,
                       fmt"{name} has no-default and not specified.")


proc get_float*(self: Options, name: string, default: float): float =  # {{{1
    return self.get_float(name, some(default))


proc get_float*(self: Options, name: string): float =  # {{{1
    ## see `get_string`
    return self.get_float(name, none(float))


# end of file {{{1
# vi: ft=nim:et:ts=4:fdm=marker:nowrap
