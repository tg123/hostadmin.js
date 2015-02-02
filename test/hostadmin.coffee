assert = require("assert")

HostAdmin = require("../lib/hostadmin").HostAdmin

describe 'HostAdmin', ->
    describe '#parse_hostfile', ->

        it "empty file", ->
            h = new HostAdmin
            h.parse_hostfile ""

            assert.deepEqual {}, h.hosts
            assert.deepEqual {}, h.groups

        it 'host ip v4', ->
            h = new HostAdmin

            h.parse_hostfile """
            127.0.0.1 domain
            #127.0.0.1 domain

            127.0.0.1 domain2
            
            """

            assert.deepEqual h.hosts['domain'], [
                {"ip":"127.0.0.1","host":["domain"],"comment":"","disabled":false,"line_no":0,"hide":false}
                {"ip":"127.0.0.1","host":["domain"],"comment":"","disabled":true, "line_no":1,"hide":false}
            ]

            assert.deepEqual h.hosts['domain2'], [
                {"ip":"127.0.0.1","host":["domain2"],"comment":"","disabled":false,"line_no":3,"hide":false}
            ]

        it 'host ip v6', ->
            h = new HostAdmin

            h.parse_hostfile """
             ::1 localhost
             #1::1 localhost

             #fe80::1%lo0    localhost1
            """

            assert.deepEqual h.hosts['localhost'], [
                {"ip":"::1","host":["localhost"],"comment":"","disabled":false,"line_no":0,"hide":false}
                {"ip":"1::1","host":["localhost"],"comment":"","disabled":true, "line_no":1,"hide":false}
            ]

            assert.deepEqual h.hosts['localhost1'], [
                {"ip":"fe80::1%lo0","host":["localhost1"],"comment":"","disabled":true,"line_no":3,"hide":false}
            ]

            
