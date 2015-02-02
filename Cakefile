fs = require 'fs'
{print} = require 'util'
{spawn, exec} = require 'child_process'

# modified from https://github.com/jashkenas/coffeescript/blob/master/Cakefile

# Build the CoffeeScript language from source.
build = (cb) ->
    files = fs.readdirSync 'src'
    files = ('src/' + file for file in files when file.match(/\.coffee$/))
    run 'coffee', ['-c', '-o', 'lib/'].concat(files), cb

# Run a CoffeeScript through our node/coffee interpreter.
run = (bin, args, cb) ->
    proc =         spawn bin, args
    proc.stdout.on 'data', (buffer) -> console.log buffer.toString()
    proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
    proc.on        'exit', (status) ->
        process.exit(1) if status != 0
        cb() if typeof cb is 'function'


task 'build', 'Run full build', ->
    invoke 'build:parser'
    invoke 'build:compile'

task 'build:compile', 'complie coffee', ->
    build()

task 'build:parser', 'rebuild the Jison parser', ->
    jison = require 'jison'
    grammar = fs.readFileSync("./src/hostadmin.jison", "utf8")
    code = new jison.Generator(grammar).generate()
    fs.writeFileSync "lib/hosts_parser.js", code

task "test", "run tests", ->
    invoke 'build'

    run "mocha", [
        '--colors'
        '--compilers=coffee:coffee-script/register'
        'test/*.coffee'
        ]


task 'clean', 'clean up', ->
    files = fs.readdirSync 'lib'
    fs.unlink ('lib/' + file) for file in files when file.match(/\.js$/)
