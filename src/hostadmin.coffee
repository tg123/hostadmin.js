host_parser = require("./hosts_parser")

@parse_hostfile = (hosts_file_content) ->
    
    parser = host_parser.parser
    parser.yy =
        group_id   : 0
        hosts      : []
        groups     : []

        root_group :
            name : "Ungrouped"
            hosts : []

        hide_below : false

    parser.yy.cur_group = parser.yy.root_group

    parser.parse(hosts_file_content)

    return {
        hosts : parser.yy.hosts
        groups: parser.yy.groups
    }

