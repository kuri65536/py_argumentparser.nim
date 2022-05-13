##[
py_argparse_str.nim
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
  OptionsActionString* = ref object of OptionsAction  # {{{1
    default: Option[string]
    choices: seq[string]

  OptionString* = ref object of OptionBase  # {{{1
    val: string
    choices: seq[string]
    default: string


proc to_string*(self: OptionString): string =  # {{{1
    return self.val


proc add_argument*(self: ArgumentParser,  # string {{{1
                   opt_short: char, opt_long: string, default: Option[string],
                   dest = "", choices: seq[string] = @[],
                  action: ActionFunc = nil, help_text = ""): void =
    var act = OptionsActionString(action: action, help_text: help_text,
                                  default: default)
    self.actions.add(act)
    OptionsAction(act).set_opt_name(opt_short, opt_long, dest)

    if len(choices) > 0:
        act.choices = choices


proc add_argument*(self: ArgumentParser,  # string-2 {{{1
                   opt_short: char, opt_long, default: string, dest = "",
                   choices: seq[string] = @[],
                   action: ActionFunc = nil, help_text = ""): void =
    ##[ add a string argument to parser.

        :opt_short: an argument like '-s=...'
        :opt_long:  an argument like '--string=...'
        :default:   a value if no arguments specified.
        :dest:      a name of the key in results
        :action:    a function called if argument was specifed.
        :help_text: text message to output in `print_help`
    ]##
    self.add_argument(opt_short, opt_long, some(default), dest,
                      choices, action, help_text)


method set_default(self: OptionsActionString, opts: var Options  # {{{1
                   ): void =
    var (name, val) = (self.dest_name, "")
    if self.default.isSome:
        val = self.default.get()
    elif len(self.choices) > 0:
        val = self.choices[0]
    else:
        return

    if len(opts) > 0 and opts.hasKey(name):
        # info(fmt"set_default(override): {self.default} => {name}")
        var opt = OptionString(opts[name])
        opt.val = self.default.get()
    else:
        # info(fmt"set_default: {self.default} => {name}")
        opts[name] = OptionString(val: val)



method action_default(self: OptionsActionString, opts: var Options,  # {{{1
                      key, val: string): void =
    if len(self.choices) > 0:
        if not self.choices.contains(val):
            return
    var name = self.dest_name
    if opts.hasKey(name):
        var opt = OptionString(opts[name])
        opt.val = val
    else:
        var opt = OptionString(val: val)
        opts[name] = opt


proc get_string*(self: Options, name: string,  # {{{1
                 default: Option[string]): string =
    if self.hasKey(name):
        var tmp = OptionString(self[name])
        return tmp.val
    if default.isSome:
        return default.get()
    raise newException(KeyError,
                       fmt"{name} has no-default and not specified.")


proc get_string*(self: Options, name, default: string): string =  # {{{1
    ##[ get a string argument from the parser result,
        return `default` if `name` not in the result.
    ]##
    return self.get_string(name, some(default))


proc get_string*(self: Options, name: string): string =  # {{{1
    ##[ get a string argument from the parser result, raise KeyError
        if `name` not in the result.

        `name` will be follow in bellow rules.

        1. `dest` in `add_arguments` if specified
        2. `opt_long` in `add_arguments` if specified
        3. `opt_short` in `add_arguments` if specified
    ]##
    return self.get_string(name, none(string))


# end of file {{{1
# vi: ft=nim:et:ts=4:fdm=marker:nowrap
