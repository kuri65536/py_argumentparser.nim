##[
py_argumentparser.nim
---------------------------
a yet another options parser instead of nim default `parseopt`.

- python like api, not compatible with nim's parseopt.
- but strict type checking with nim language.
- simply example:

.. code-block:: nim

  import py_argumentparser
  var parser = initArgumentParser()
  parser.add_argument('t', "test", default = "is ng")
  var opts = parser.parse_args()
  echo "test: " & opts.get_string("test")

this will be:

.. code-block:: console

  $ test -t="is ok"
  is ok

see tests folder to see more types of arguments.


license
-----------
Copyright (c) 2020, shimoda as kuri65536 _dot_ hot mail _dot_ com
                      ( email address: convert _dot_ to . and joint string )

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.
]##
import os
import options
import strutils
import tables

import py_argumentparser/private/py_argparse_bool
import py_argumentparser/private/py_argparse_common
import py_argumentparser/private/py_argparse_float
import py_argumentparser/private/py_argparse_int
import py_argumentparser/private/py_argparse_str

export ActionResult, initArgumentParser
export get_boolean, get_float, get_integer, get_string
export add_argument


type  # {{{1
  ActionExit* = enum  # {{{1
    help = 1
    version

  ArgumentType = enum  # {{{1
    argument_is_value = 0
    argument_is_option_without_value = 1
    argument_is_option_with_value = 2

  OptionStrings* = ref object of OptionBase  # {{{1
    vals: seq[string]


var help_parser {.threadvar.}: ArgumentParser


proc help_init(self: ArgumentParser): void =  # {{{1
    self.prog = os.getAppFilename()  # cache (I realy dont no for speed up)
    help_parser = self


proc parse_help_string(self: ArgumentParser, src: string): string =  # {{{1
    var ret = src
    ret = ret.replace("%(prog)", self.prog)
    return src


proc print_help*(self: ArgumentParser): void =  # {{{1
    ##[ print help message from `ArgumentParser` contents.
    ]##
    echo self.parse_help_string(self.usage)
    echo self.parse_help_string(self.description)

    var optionals: seq[OptionsAction]
    var required: seq[OptionsAction]

    for act in self.actions:
        if act.required:
            required.add(act)
        else:
            optionals.add(act)

    for tup in [(acts: required, msg: self.usage_required),
                (acts: optionals, msg: self.usage_optionals)]:
        if len(tup.acts) < 1:
            continue
        echo self.parse_help_string(tup.msg)
        for i in tup.acts:
            echo i.to_help()

    echo self.parse_help_string(self.epilog)


proc print_version*(self: ArgumentParser): void =  # {{{1
    ##[ print simple version message from `ArgumentParser` contents.
    ]##
    echo self.parse_help_string(self.usage_version)


proc `$`*(opt: OptionBase): string =  # {{{1
    if opt of OptionString:
        return OptionString(opt).to_string()
    if opt of OptionInteger:
        return OptionInteger(opt).to_string()
    if opt of OptionFloat:
        return OptionFloat(opt).to_string()
    if opt of OptionBoolean:
        return OptionBoolean(opt).to_string()
    return "none"



proc action_help*(key, val: string): ActionResult {.gcsafe.} =  # {{{1
    help_parser.print_help()
    system.quit(1)


proc action_version*(key, val: string): ActionResult =  # {{{1
    help_parser.print_version()
    system.quit(1)


proc add_argument*(self: ArgumentParser,  # action only {{{1
                   opt_short: char, opt_long: string, dest = "", nargs = 1,
                   action: ActionFunc = nil, help_text = ""): void =
    ##[add an argument to call action functions for complex behavior.
    ]##
    var act = OptionsAction()
    discard act.set_action(action
              ).set_helptext(help_text
              ).set_withoutvalue(nargs < 1
              )
    self.actions.add(act)
    act.set_opt_name(opt_short, opt_long, dest)


proc add_argument*(self: ArgumentParser,  # seq[string] {{{1
                  opt_short, opt_long: string, default: seq[string],
                   dest = "", nargs = 1,
                  action: ActionFunc = nil): void =
    # seq[string]
    discard


proc add_argument*(self: ArgumentParser,  # exit {{{1
                   opt_short: char, opt_long: string, default: ActionExit,
                   action: ActionFunc = nil, help_text = ""): void =
    ##[add a boolean argument (special cases)
        if the argument were specified, show messages and exit the program.
    ]##
    var act = initOptionsActionBoolean(some(true), help_text)
    OptionsAction(act).set_opt_name(opt_short, opt_long, "")
    if isNil(action):
        if default == ActionExit.help:
            discard act.set_action(action_help)
        if default == ActionExit.version:
            discard act.set_action(action_version)
    self.actions.add(act)


    #[ TODO(shimoda): not impemented, yet
method action_default(act: OptionsActionStrings, opts: var Options,  # {{{1
                      key, val: string): void =
        if not opts.hasKey(name):
            opts[key] = OptionStrings(vals: @[val],
                                       dest_type: OptionDestType.str_seq)
        else:
            try:
                var tmp = OptionStrings()  # opts[name])
                tmp.vals.add(val)
            except:
                discard
    ]#


proc parse_known_args*(self: ArgumentParser, args: seq[string]  # {{{1
                       ): tuple[opts: Options, args: seq[string]] =
    ##[ parse the specified arguments.
        returns parsed results and unknown arguments.
    ]##
    var ret1 = initTable[string, OptionBase]()
    var ret2: seq[string] = @[]

    for act in self.actions:
        act.set_default(ret1)
    self.help_init()

    proc match_option(act: OptionsAction,  # {{{1
                      s: char, l: string): ArgumentType =
        let f = act.is_match(s, l)
        if f == option_match.unmatch:
            return argument_is_value
        if act of OptionsActionBoolean:
            return argument_is_option_without_value
        if f == option_match.match_wo_value:
            return argument_is_option_without_value
        return argument_is_option_with_value

    proc parse_one_arg(arg: string  # {{{1
                       ): tuple[typ: ArgumentType, act: OptionsAction] =
        var s_name, l_name: string
        if arg.startsWith("--"):
            l_name = arg[2 ..^ 1]
        elif not arg.startsWith("-"):
            return (argument_is_value, nil)
        else:
            s_name = arg[1 ..^ 2]
            for j in s_name:
                for i in self.actions:
                    var typ = match_option(i, j, "")
                    if typ == argument_is_value:
                        continue
                    if typ == argument_is_option_without_value:
                        i.run_action(ret1, $j)
                    break  # skip options with value `ab` of like `-abc value`
            s_name = arg[^1 .. ^1]

        var short = if len(s_name) <= 0: invalid_short_names[0]
                    else:               s_name[0]
        for i in self.actions:
            var n = match_option(i, short, l_name)
            if n == argument_is_value: continue
            return (n, i)
        return (argument_is_value, nil)

    # loop {{{1
    var arg_opt: OptionsAction = nil
    for i in args:
        if not isNil(arg_opt):
            arg_opt.run_action(ret1, i)
            arg_opt = nil
            continue
        var (typ, act) = parse_one_arg(i)
        # echo "loop-check: ", typ, "-", i
        case typ:
        of argument_is_option_without_value:
            act.run_action(ret1, "")
        of argument_is_option_with_value:
            arg_opt = act
        else:
            ret2.add(i)
    return (ret1, ret2)


proc parse_args*(self: ArgumentParser, args: seq[string]  # {{{1
                 ): Options =
    ##[ parse the specified arguments,
        raise ValueError if arguments has unknown arguments.
    ]##
    var (ret1, ret2) = self.parse_known_args(args)

    if len(ret2) > 0:
        raise newException(ValueError, "unknown arguments: " & $ret2)
    return ret1


proc parse_known_args*(self: ArgumentParser  # {{{1
                       ): tuple[opts: Options, args: seq[string]] =
  when declared(paramCount):
    var args: seq[string] = @[]
    for i in countup(1, paramCount()):
        args.add(paramStr(i).string)
    return self.parse_known_args(args)
  else:
    return self.parse_known_args(@[])


proc parse_args*(self: ArgumentParser): Options =  # {{{1
  when declared(paramCount):
    var args: seq[string] = @[]
    for i in countup(1, paramCount()):
        args.add(paramStr(i).string)
    return self.parse_args(args)
  else:
    return self.parse_args(@[])


# end of file {{{1
# vi: ft=nim:et:ts=4:fdm=marker:nowrap
