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
fs = require 'fs'
kitchen = require './kitchen'

HELP_TEXT =
  bake: [ 'Usage: kitchen bake [recipe]' ]
  help: [ 'Usage: kitchen help [subcommand]',
    '',
    'Available subcommands:',
    '   bake   Create files from recipe files',
    '   help   Obtain subcommand information']
  unknown: [ "kitchen: help: Unknown subcommand" ]

doBake = (params) ->
  [recipe, more...] = params
  if not recipe?
    stderr.write "kitchen: Recipe file required\n"
    process.exit 1
  if not fs.existsSync recipe
    stderr.write "kitchen: cannot stat '" + recipe + "': No such file or directory\n"
    process.exit 1
  recipeText = fs.readFileSync recipe
  try
    recipeObj = JSON.parse recipeText
  catch
    stderr.write "kitchen: Unrecognized recipe file format\n"
    process.exit 1
  kitchen.bake recipeObj

doHelp = (params) ->
  [subcommand, more...] = params
  subcommand ?= 'help'
  help = HELP_TEXT[subcommand]
  help ?= HELP_TEXT["unknown"]
  stdout.write(x + '\n') for x in help

commands =
  bake: doBake
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
