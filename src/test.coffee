
fs = require('fs')
HostAdmin = require("./hostadmin").HostAdmin

fs.readFile '/etc/hosts', 'utf8', (err,data) ->


    ha = new HostAdmin


    ha.parse_hostfile(data)

    #console.log(ha.to_hostfile())
    h = ha.hosts['localhost']
    console.log(h)

    h = ha.hosts['localhost'][0]

    ha.host_toggle('localhost', h)

    #console.log(ha.to_hostfile())


    #console.log(ha)
    #

    #d = hostadmin.parse_hostfile(data)
    #console.log(d)
    #d = hostadmin.parse_hostfile(data)
    #console.log(d)
    #d = hostadmin.parse_hostfile(data)
    #console.log(d)
    #d = hostadmin.parse_hostfile(data)
    #console.log(d)
    #d = hostadmin.parse_hostfile(data)
    #console.log(d)
    ##for i in d.hosts
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




