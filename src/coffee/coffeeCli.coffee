# coffeeCli.coffee
# Copyright 2014 Patrick Meade.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#----------------------------------------------------------------------------

{stderr, stdout} = process

HELP_TEXT =
  help: [ 'Usage: kitchen help [subcommand]',
    '',
    'Available subcommands:',
    '   help   Obtain subcommand information']
  unknown: [ "kitchen: help: Unknown subcommand" ]
  
doHelp = (params) ->
  [subcommand, more...] = params
  subcommand ?= 'help'
  help = HELP_TEXT[subcommand]
  help ?= HELP_TEXT["unknown"]
  stdout.write(x + '\n') for x in help

commands =
  help: doHelp

#--------------------------------------------------------

exports.run = ->
  argv = require('yargs')
    .usage('Usage: $0 [subcommand]')
    .example('$0 help', 'Show a listing of subcommands')
    .demand(1)
    .argv

  [subcommand, params...] = argv._
  
  if not commands[subcommand]?
    stderr.write "kitchen: Unknown subcommand '" + subcommand + "'\n"
    process.exit 1

  commands[subcommand](params)

#----------------------------------------------------------------------------
# end of coffeeCli.coffee
