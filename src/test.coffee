
fs = require('fs')
host_parser = require("./hosts_parser")

fs.readFile '/etc/hosts', 'utf8', (err,data) ->

        host_parser.parser.parse(data)

    
        for i in host_parser.hosts
            
            console.log( i)
            #console.log(host_parser.hosts[i])

        console.log host_parser.groups



