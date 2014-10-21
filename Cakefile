fs = require 'fs'
{print} = require 'util'
{spawn, exec} = require 'child_process'


# modified from https://github.com/jashkenas/coffeescript/blob/master/Cakefile

# Build the CoffeeScript language from source.
build = (cb) ->
    files = fs.readdirSync 'src'
    files = ('src/' + file for file in files when file.match(/\.coffee$/))
    run ['-c', '-o', 'lib/'].concat(files), cb

# Run a CoffeeScript through our node/coffee interpreter.
run = (args, cb) ->
    proc =         spawn 'coffee', args
    proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
    proc.on        'exit', (status) ->
    process.exit(1) if status != 0
        cb() if typeof cb is 'function'


task 'build', 'Run full build', ->
    invoke 'build:parser'
    invoke 'build:compile'

task 'build:compile', 'complie coffee', ->
    build()

task 'build:parser', 'rebuild the Jison parser', (options) ->
    jison = require 'jison'
    grammar = fs.readFileSync("./src/hostadmin.jison", "utf8")
    code = new jison.Generator(grammar).generate()
    fs.writeFileSync "lib/hosts_parser.js", code

task 'clean', 'clean up', (options) ->
    files = fs.readdirSync 'lib'
    fs.unlink ('lib/' + file) for file in files when file.match(/\.js$/)
