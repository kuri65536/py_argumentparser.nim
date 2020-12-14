#[
## license
Copyright (c) 2020, shimoda as kuri65536 _dot_ hot mail _dot_ com
                      ( email address: convert _dot_ to . and joint string )

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file,
You can obtain one at https://mozilla.org/MPL/2.0/.
]#
import os
import strformat
import strutils
import tables

type  # {{{1
  int_or_nil* = ref object of RootObj  # {{{1
    value: int

  float_or_nil* = ref object of RootObj  # {{{1
    value: float

  ActionResult* = enum  # {{{1
    ok = 0

  ActionExit* = enum  # {{{1
    help = 1
    version

  ArgumentType = enum  # {{{1
    argument_is_value = 0
    argument_is_option_without_value = 1
    argument_is_option_with_value = 2

  ActionFunc* = proc(key, val: string): ActionResult  # {{{1

  OptionsAction* = ref object of RootObj  # {{{1
    short_name: char
    long_name, dest_name: string
    action: ActionFunc
    help_text: string

  OptionsActionString* = ref object of OptionsAction  # {{{1
    default: string
    choices: seq[string]

  OptionsActionBoolean* = ref object of OptionsAction  # {{{1
    default: bool

  OptionsActionInteger* = ref object of OptionsAction  # {{{1
    default: int_or_nil

  OptionsActionFloat* = ref object of OptionsAction  # {{{1
    default: float_or_nil

  ArgumentParser* = ref object of RootObj  # {{{1
    usage, usage_optionals, usage_required: string
    actions: seq[OptionsAction]

  OptionBase* = ref object of RootObj  # {{{1
    discard

  OptionString* = ref object of OptionBase  # {{{1
    val*: string
    choices: seq[string]
    default: string

  OptionInteger* = ref object of OptionBase  # {{{1
    val: int

  OptionFloat* = ref object of OptionBase  # {{{1
    val: float

  OptionBoolean* = ref object of OptionBase  # {{{1
    val*: bool

  OptionStrings* = ref object of OptionBase  # {{{1
    vals: seq[string]

  Options* = Table[string, OptionBase]  # {{{1


var help_parser: ArgumentParser = nil
var int_nil*: int_or_nil = nil
var float_nil*: float_or_nil = nil


proc initArgumentParser*(usage = ""): ArgumentParser =  # {{{1
    var usage_msg = if len(usage) < 1: usage
                    else:              "impl."
    var ret = ArgumentParser(actions: @[],
                             usage: usage)
    return ret


proc parse_help_string(self: ArgumentParser, src: string): string =  # {{{1
    discard


proc print_help*(self: ArgumentParser): void =  # {{{1
    echo self.parse_help_string(self.usage)

    var optionals: seq[OptionsAction]
    var required: seq[OptionsAction]

    if len(optionals) > 0:
        echo self.parse_help_string(self.usage_optionals)
        for i in optionals:
            echo self.parse_help_string(i.help_text)
    if len(required) > 0:
        echo self.parse_help_string(self.usage_required)
        for i in required:
            echo self.parse_help_string(i.help_text)

proc `$`*(opt: OptionBase): string =  # {{{1
    if opt of OptionString:
        return OptionString(opt).val
    if opt of OptionInteger:
        return $OptionInteger(opt).val
    if opt of OptionFloat:
        return $OptionFloat(opt).val
    if opt of OptionBoolean:
        return $OptionBoolean(opt).val
    return "none"

proc to_help(self: OptionsAction): string =  # {{{1
    var ret = ""
    if self.short_name != '\0':
        ret = fmt"-{self.short_name}"
    if len(self.long_name) > 0:
        if len(ret) > 0: ret = ret & ", "
        ret &= fmt"--{self.long_name}"
    ret = fmt"    {ret:20}: " & self.help_text
    return ret


proc action_help*(key, val: string): ActionResult =  # {{{1
    help_parser.print_help()
    system.quit(1)


proc action_version*(key, val: string): ActionResult =  # {{{1
    system.quit(1)


proc set_opt_name(self: var OptionsAction, short, long, dest: string  # {{{1
                  ): void =
    self.short_name = '\0'
    if len(short) < 1:
        discard
    elif len(short) == 1:
        self.short_name = short[0]
    elif short.startsWith("-"):
        self.short_name = short[1]
    else:
        assert false

    self.long_name = if long.startsWith("--"): long[2..^1]
                     else:                     long
    var name = if len(dest) > 0: dest
               else:             self.long_name
    if name.startsWith("--"):
        name = name[2..^1]
    if len(name) < 1 and self.short_name != '\0':
        name = $self.short_name
    self.dest_name = name
    # echo fmt"set_opt_name: {self.dest_name} <= {short}, {long}"


proc add_argument*(self: ArgumentParser,  # string {{{1
                  opt_short, opt_long: string, default = "", dest = "",
                  choices: seq[string] = @[], nargs = 0,
                  action: ActionFunc = nil, help_text = ""): void =
    var act = OptionsActionString(action: action, help_text: help_text,
                                  default: default)
    self.actions.add(act)
    OptionsAction(act).set_opt_name(opt_short, opt_long, dest)

    if len(choices) > 0:
        act.choices = choices
    if not isNil(action):
        act.action = action


proc add_argument*(self: ArgumentParser,  # seq[string] {{{1
                  opt_short, opt_long: string, default: seq[string],
                  dest = "", nargs = 0,
                  action: ActionFunc = nil): void =
    # seq[string]
    discard


proc add_argument*(self: ArgumentParser,  # int {{{1
                   opt_short, opt_long: string, default: int_or_nil, dest = "",
                   action: ActionFunc = nil, help_text = ""): void =
    var act = OptionsActionInteger(default: default,
                               action: action, help_text: help_text)
    OptionsAction(act).set_opt_name(opt_short, opt_long, dest)
    self.actions.add(act)

    if not isNil(action):
        act.action = action


proc add_argument*(self: ArgumentParser,  # int {{{1
                   opt_short, opt_long: string, default: int, dest = "",
                   action: ActionFunc = nil, help_text = ""): void =
    add_argument(self, opt_short, opt_long, int_or_nil(value: default), dest,
                 action, help_text)


proc add_argument*(self: ArgumentParser,  # float {{{1
                   opt_short, opt_long: string, default: float_or_nil,
                   dest = "", action: ActionFunc = nil, help_text = ""): void =
    var act = OptionsActionFloat(
            default: default,
            action: action, help_text: help_text)
    OptionsAction(act).set_opt_name(opt_short, opt_long, dest)
    self.actions.add(act)

    if not isNil(action):
        act.action = action


proc add_argument*(self: ArgumentParser,  # float {{{1
                   opt_short, opt_long: string, default: float, dest = "",
                   action: ActionFunc = nil, help_text = ""): void =
    add_argument(self, opt_short, opt_long, float_or_nil(value: default), dest,
                 action, help_text)


proc add_argument*(self: ArgumentParser,  # bool {{{1
                   opt_short, opt_long: string, default: bool,
                   dest = "", nargs = 0,
                   action: ActionFunc = nil, help_text = ""): void =
    var act = OptionsActionBoolean(action: action,
                                default: default, help_text: help_text)
    OptionsAction(act).set_opt_name(opt_short, opt_long, dest)
    self.actions.add(act)


proc add_argument*(self: ArgumentParser,  # exit {{{1
                   opt_short, opt_long: string, default: ActionExit,
                   action: ActionFunc = nil, help_text = ""): void =
    var act = OptionsActionBoolean(default: true,
                                help_text: help_text)
    OptionsAction(act).set_opt_name(opt_short, opt_long, "")
    if isNil(action):
        if default == ActionExit.help:
            act.action = action_help
        if default == ActionExit.version:
            act.action = action_version
    self.actions.add(act)


method set_default(self: OptionsAction, opts: var Options): void {.base.} =  # {{{1
    discard


method set_default(self: OptionsActionString, opts: var Options): void =
    var (name, val) = (self.dest_name, "")
    if len(self.default) > 0:
        val = self.default
    elif len(self.choices) > 0:
        val = self.choices[0]
    else:
        return

    if len(opts) > 1 and opts.hasKey(name):
        # info(fmt"set_default(override): {self.default} => {name}")
        var opt = OptionString(opts[name])
        opt.val = self.default
    else:
        # info(fmt"set_default: {self.default} => {name}")
        opts.add(name, OptionString(val: val))


method set_default(self: OptionsActionBoolean, opts: var Options): void =
    opts[self.dest_name] = OptionBoolean(val: self.default)


method set_default(self: OptionsActionInteger, opts: var Options): void =
    if isNil(self.default):
        return
    opts[self.dest_name] = OptionInteger(val: self.default.value)


method set_default(self: OptionsActionFloat, opts: var Options): void =
    if isNil(self.default):
        return
    opts[self.dest_name] = OptionFloat(val: self.default.value)


method action_default(self: OptionsAction, opts: var Options,  # {{{1
                      key, val: string): void {.base.} =
    if self of OptionsActionInteger:
        opts[key] = OptionInteger(val: parseInt(val))
    elif self of OptionsActionFloat:
        opts[key] = OptionFloat(val: parseFloat(val))
    elif self of OptionsActionBoolean:
        var act = OptionsActionBoolean(self)
        opts[key] = OptionBoolean(val: not act.default)
    #[ TODO(shimoda): not impemented, yet
    elif self of OptionsActionStrings:
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


method action_default(self: OptionsActionString, opts: var Options,
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
        opts.add(name, opt)


proc run_action(self: OptionsAction, opts: var Options,  # {{{1
                val: string): void =
    var name = self.dest_name
    if not isNil(self.action):
        discard self.action(name, val)
        return
    self.action_default(opts, name, val)


proc parse_known_args*(self: ArgumentParser, args: seq[string]  # {{{1
                       ): tuple[opts: Options, args: seq[string]] =
    var ret1 = initTable[string, OptionBase]()
    var ret2: seq[string] = @[]

    for act in self.actions:
        act.set_default(ret1)

    proc match_option(act: OptionsAction, s: char, l: string): int =  # {{{1
        if s != '\0' and s != act.short_name:
            return 0
        if len(l) > 0 and l != act.long_name:
            return 0
        if act of OptionsActionBoolean:
            return 1
        return 2

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
                    if typ == 0:
                        continue
                    if typ == 1:
                        i.run_action(ret1, $j)
                    break  # skip options with value `ab` of like `-abc value`
            s_name = arg[^1 .. ^1]

        var short = if len(s_name) <= 0: '\0'
                    else:               s_name[0]
        for i in self.actions:
            var n = match_option(i, short, l_name)
            case n:
            of 1:
                return (argument_is_option_without_value, i)
            of 2:
                return (argument_is_option_with_value, i)
            else:  # 0
                continue
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
    var (ret1, ret2) = self.parse_known_args(args)

    if len(ret2) > 0:
        raise newException(ValueError, "unknown arguments: " & $ret2)
    return ret1


proc parse_known_args*(self: ArgumentParser  # {{{1
                       ): tuple[opts: Options, args: seq[string]] =
    var args: seq[string] = @[]
    for i in countup(1, paramCount()):
        args.add(paramStr(i).string)
    return self.parse_known_args(args)


proc parse_args*(self: ArgumentParser): Options =  # {{{1
    var args: seq[string] = @[]
    for i in countup(1, paramCount()):
        args.add(paramStr(i).string)
    return self.parse_args(args)


proc get_string*(self: Options, name, default: string): string =  # {{{1
    if self.hasKey(name):
        var tmp = OptionString(self[name])
        return tmp.val
    return default


proc get_boolean*(self: Options, name: string, default: bool): bool =  # {{{1
    if self.hasKey(name):
        var tmp = OptionBoolean(self[name])
        return tmp.val
    return default


proc get_integer*(self: Options, name: string, default: int): int =  # {{{1
    if self.hasKey(name):
        var tmp = OptionInteger(self[name])
        return tmp.val
    return default


proc get_float*(self: Options, name: string, default: float): float =  # {{{1
    if self.hasKey(name):
        var tmp = OptionFloat(self[name])
        return tmp.val
    return default


# end of file {{{1
# vi: ft=nim:et:ts=4:fdm=marker:nowrap
