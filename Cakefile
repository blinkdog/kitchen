# Cakefile
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

{exec} = require 'child_process'

task 'clean', 'Remove previous build', ->
  clean()

task 'rebuild', 'Rebuild the module', ->
  clean -> compile -> copyJs -> test()
 
task 'test', 'Test with Mocha specs', ->
  test()

clean = (callback) ->
  exec 'rm -fR lib/*', (err, stdout, stderr) ->
    throw err if err
    callback?()

compile = (callback) ->
  exec 'node_modules/coffee-script/bin/coffee -o lib/ -c src/coffee', (err, stdout, stderr) ->
    throw err if err
    callback?()

copyJs = (callback) ->
  exec 'cp src/js/* lib/', (err, stdout, stderr) ->
    throw err if err
    callback?()

test = (callback) ->
  exec 'node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register --recursive', (err, stdout, stderr) ->
    console.log stdout + stderr
    callback?() if stderr.indexOf("AssertionError") < 0

#----------------------------------------------------------------------
# end of Cakefile
