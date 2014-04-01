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
url = require 'url'

error = require './error'
nutrition = require './hash'
useful = require './useful'

KITCHEN_CONFIG_JSON = 'config.json'
KITCHEN_DIRECTORY = '.kitchen'
PANTRY_DIRECTORY = 'pantry'

addPantry = (pantryType, pantryLoc, configFile) ->
  configJson = fs.readFileSync configFile
  try
    configObj = JSON.parse configJson
  catch
    error.badJson configFile
  configObj.pantry[pantryType].push url.format url.parse pantryLoc
  configObj.pantry[pantryType] = configObj.pantry[pantryType].unique()
  fs.writeFileSync configFile, JSON.stringify configObj, undefined, 2

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

#----------------------------------------------------------------------------

exports.addIngredient = (ingredientPath, options) ->
  # validate configuration
  kitchenDir = options?.kitchen || getKitchenDirectory()
  pantryDir = path.normalize path.join kitchenDir, PANTRY_DIRECTORY
  error.noPantry() if not fs.existsSync pantryDir
  # load the ingredient data to be added to the pantry
  data = fs.readFileSync ingredientPath
  # determine where the ingredient hashes will live
  result =
    dir: {}
    hash: {}
    path: {}
  for algorithm in [ 'ripemd160', 'sha512', 'whirlpool' ]
    result.hash[algorithm] = nutrition.hashIt algorithm, data
    result.dir[algorithm] = path.normalize path.join pantryDir, algorithm
    fs.mkdirSync result.dir[algorithm] if not fs.existsSync result.dir[algorithm]
    result.path[algorithm] = path.normalize path.join result.dir[algorithm], result.hash[algorithm]
  # write the file to the primary destination
  fs.writeFileSync result.path['sha512'], data
  # link the others to the primary
  fs.symlinkSync result.path['sha512'], result.path['ripemd160']
  fs.symlinkSync result.path['sha512'], result.path['whirlpool']

exports.addLocalPantry = (pantryLoc, options) ->
  kitchenDir = options?.kitchen || getKitchenDirectory()
  configJsonFile = path.normalize path.join kitchenDir, KITCHEN_CONFIG_JSON
  addPantry 'local', pantryLoc, configJsonFile

exports.addRemotePantry = (pantryLoc, options) ->
  kitchenDir = options?.kitchen || getKitchenDirectory()
  configJsonFile = path.normalize path.join kitchenDir, KITCHEN_CONFIG_JSON
  addPantry 'remote', pantryLoc, configJsonFile

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
  kitchenDir = options?.kitchen || getKitchenDirectory()
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
