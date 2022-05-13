##[
py_argparse_common.nim
---------------------------

license
-----------
Copyright (c) 2020, shimoda as kuri65536 _dot_ hot mail _dot_ com
                      ( email address: convert _dot_ to . and joint string )

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.
]##
import strutils
import tables


type  # {{{1
  ActionResult* = enum  # {{{1
    ok = 0

  ActionFunc* = proc(key, val: string): ActionResult  # {{{1

  OptionsAction* = ref object of RootObj  # {{{1
    short_name*: char
    long_name*, dest_name*: string
    required*: bool
    action*: ActionFunc
    help_text*: string
    without_value*: bool

  ArgumentParser* = ref object of RootObj  # {{{1
    ##[ parse arguments by specified actions.

        - actions will be added by `add_argument`
        - then call `parse_args` or `parse_known_args` to parse arguments
        - after that, arguments results will be returned and its
            values can be accessed by key names
    ]##
    usage*, description*, epilog*, usage_optionals*, usage_required*: string
    usage_version*: string
    prog*: string
    actions*: seq[OptionsAction]

  OptionBase* = ref object of RootObj  # {{{1
    discard

  Options* = Table[string, OptionBase]  # {{{1


let invalid_short_names* = ['\0', ' ']


proc initArgumentParser*(usage = ""): ArgumentParser =  # {{{1
    var usage_msg = if len(usage) < 1: usage
                    else:              "impl."
    var ret = ArgumentParser(actions: @[],
                             usage: usage_msg)
    return ret


proc set_opt_name*(self: var OptionsAction, short: char,  # {{{1
                  long, dest: string): void =
    self.short_name = short

    self.long_name = if long.startsWith("--"): long[2..^1]
                     else:                     long
    var name = if len(dest) > 0: dest
               else:             self.long_name
    if name.startsWith("--"):
        name = name[2..^1]
    if len(name) < 1 and self.short_name not_in invalid_short_names:
        name = $self.short_name
    self.dest_name = name
    # echo fmt"set_opt_name: {self.dest_name} <= {short}, {long}"


method set_default*(self: OptionsAction, opts: var Options  # {{{1
                    ): void {.base, gcsafe, locks: "unknown" .} =
    discard


method action_default*(self: OptionsAction, opts: var Options,  # {{{1
                       key, val: string
                       ): void {.base, gcsafe, locks: "unknown".} =
    discard


# end of file {{{1
# vi: ft=nim:et:ts=4:fdm=marker:nowrap
