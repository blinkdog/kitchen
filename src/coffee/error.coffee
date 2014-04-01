# error.coffee
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

{stderr} = process

writeToStderr = (lines) ->
  stderr.write line + '\n' for line in lines

exports.noKitchen = ->
  writeToStderr [
    "kitchen: Kitchen has not been initialized.",
    "Try: 'kitchen help init'"]
  process.exit 1

exports.noUserDir = ->
  writeToStderr [
    "kitchen: Home directory is undefined."]
  process.exit 1

#----------------------------------------------------------------------------
# end of error.coffee
