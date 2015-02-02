host_parser = require("./hosts_parser")

class HostAdmin

    constructor: ->
        @lines  = []
        @hosts  = {}
        @groups = {}

    line_enable: (h) ->
        @lines[h.line_no] = @lines[h.line_no].replace(/^(\s*#)+/, "") if h.disabled
        h.disabled = false

    line_disable: (h) ->
        @lines[h.line_no] = '#' + @lines[h.line_no] if not h.disabled
        h.disabled = true

    host_toggle: (host_name, host) ->
        for h in @hosts[host_name] or []
            if h is host and host.disabled
                @line_enable(h)
            else
                @line_disable(h)

    to_hostfile: ->
        @lines.join '\n'

    parse_hostfile: (hosts_file_content) ->
        
        parser = host_parser.parser
        parser.yy =
            lines      : []

            group_id   : 0
            hosts      : []
            groups     : []

            root_group :
                name : "Ungrouped"
                hosts : []

            hide_below : false

        parser.yy.cur_group = parser.yy.root_group

        parser.parse(hosts_file_content)

        @lines  = hosts_file_content.split("\n") #TODO own lexer needed for performance reason

        @hosts  = {}

        for h in parser.yy.hosts
            for name in h.host
                @hosts[name] ?= []
                @hosts[name].push(h)

        @groups = parser.yy.groups


@HostAdmin = HostAdmin
