# kitchen.coffee
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

fs = require 'fs'
path = require 'path'

error = require './error'

KITCHEN_CONFIG_JSON = 'config.json'
KITCHEN_DIRECTORY = '.kitchen'
PANTRY_DIRECTORY = 'pantry'

getUserDirectory = ->
  switch process.platform
    when 'win32'
      process.env['USERPROFILE']
    else
      process.env['HOME']

getKitchenDirectory = ->
  path.normalize path.join getUserDirectory(), KITCHEN_DIRECTORY

isValidRecipe = (recipe) ->
  # See README.md for details on required fields
  return false if not recipe?
  return false if not recipe.name?
  return false if not recipe.length?
  #return false if not recipe.hash?
  return false if not recipe.version?
  if recipe.version is 0
    return false if not recipe.vendor?
  return false if not recipe.ingredients?
  for ingredient in recipe.ingredients
    return false if not ingredient.hash?
    keyFound = false
    for hashKey of ingredient.hash
      keyFound = true
    return false if not keyFound
    return false if not ingredient.offset?
    #return false if not ingredient.length?
  # having survived the gauntlet, we return true
  return true
  
exports.bake = (recipe, options) ->
  # validate our configuration
  error.noUserDir() if not getUserDirectory()?
  kitchenDir = options.kitchen || getKitchenDirectory()
  error.noKitchen() if not fs.existsSync kitchenDir
  # validate our recipe
  error.badRecipe recipe if not isValidRecipe recipe
  # turn on the heat and bake a file!
  console.log 'Stove currently down for maintenance.'
  console.log 'Would have baked recipe:', JSON.stringify recipe, undefined, 2

exports.init = (params, options) ->
  kitchenDir = options.kitchen || getKitchenDirectory()
  # create the kitchen directory if it does not exist
  if not fs.existsSync kitchenDir
    fs.mkdirSync kitchenDir
  # determine the pantry directory and create it, if it does not exist\
  pantryDir = path.normalize path.join kitchenDir, PANTRY_DIRECTORY
  if not fs.existsSync pantryDir
    fs.mkdirSync pantryDir
  # create the kitchen configuration if it does not exist
  configJsonFile = path.normalize path.join kitchenDir, KITCHEN_CONFIG_JSON
  if not fs.existsSync configJsonFile
    configObj =
      pantry:
        local: [ pantryDir ]
        remote: [ ]
    fs.writeFileSync configJsonFile, JSON.stringify configObj, undefined, 2
  # tell the user that the kitchen has been initialized
  process.stdout.write "Kitchen initialized at '" + kitchenDir + "'\n"

#----------------------------------------------------------------------------
# end of kitchen.coffee
