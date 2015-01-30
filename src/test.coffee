
fs = require('fs')
hostadmin = require("./hostadmin")

fs.readFile '/etc/hosts', 'utf8', (err,data) ->
    d = hostadmin.parse_hostfile(data)
    console.log(d)
    d = hostadmin.parse_hostfile(data)
    console.log(d)
    d = hostadmin.parse_hostfile(data)
    console.log(d)
    d = hostadmin.parse_hostfile(data)
    console.log(d)
    d = hostadmin.parse_hostfile(data)
    console.log(d)
    d = hostadmin.parse_hostfile(data)
    console.log(d)
    #for i in d.hosts
    #    console.log( i)
        #console.log(parser.yy.hosts[i])

    #console.log("aaaaF" , parser.yy.hosts[6])
    #console.log(parser.yy)
    #console.log parser.yy.groups
    
    #hostadmin.update_content(data)
    #hostadmin.update_content(data)
    #hostadmin.update_content(data)
    #hostadmin.update_content(data)
    #hostadmin.update_content(data)




