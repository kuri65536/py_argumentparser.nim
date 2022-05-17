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
import tables

import py_argparse_common


type  # {{{1
  OptionsActionBoolean* = ref object of OptionsAction  # {{{1
    default: Option[bool]

  OptionBoolean* = ref object of OptionBase  # {{{1
    val: bool


proc initOptionsActionBoolean*(default: Option[bool],  # {{{1
                               help_text: string): OptionsActionBoolean =
    result = OptionsActionBoolean(default: default)
    discard result.set_helptext(help_text
                 ).set_withoutvalue(true)


proc to_string*(self: OptionBoolean): string =  # {{{1
    return $self.val


proc add_argument*(self: ArgumentParser,  # bool {{{1
                   opt_short: char, opt_long: string, default: Option[bool],
                   dest = "",
                   action: ActionFunc = nil, help_text = ""): void =
    var act = initOptionsActionBoolean(
                                default = default, help_text = help_text)
    discard act.set_action(action)
    OptionsAction(act).set_opt_name(opt_short, opt_long, dest)
    self.actions.add(act)


proc add_argument*(self: ArgumentParser,  # bool {{{1
                   opt_short: char, opt_long: string, default: bool,
                   dest = "", action: ActionFunc = nil, help_text = ""): void =
    ##[add a boolean argument to parser.
        if the argument were specified, set the value to an opposite
        from its default.
    ]##
    self.add_argument(opt_short, opt_long, some(default),
                      dest, action, help_text)



method set_default(self: OptionsActionBoolean, opts: var Options  # {{{1
                   ): void =
    if self.default.isNone:
        return
    opts.set_option(self, OptionBoolean(val: self.default.get()))


method action_default(act: OptionsActionBoolean, opts: var Options,  # {{{1
                      key, val: string): void =
    opts.set_option(act, OptionBoolean(val: not act.default.get()))


proc get_boolean*(self: Options, name: string, default: Option[bool]  # {{{1
                  ): bool =
    if self.hasKey(name):
        var tmp = OptionBoolean(self[name])
        return tmp.val
    if default.isSome:
        return default.get()
    raise newException(KeyError,
                       fmt"{name} has no-default and not specified.")


proc get_boolean*(self: Options, name: string, default: bool): bool =  # {{{1
    return self.get_boolean(name, some(default))


proc get_boolean*(self: Options, name: string): bool =  # {{{1
    ## see `get_string`
    return self.get_boolean(name, none(bool))


# end of file {{{1
# vi: ft=nim:et:ts=4:fdm=marker:nowrap
