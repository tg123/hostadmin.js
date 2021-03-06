assert = require("assert")

HostAdmin = require("../lib/hostadmin").HostAdmin

describe 'HostAdmin', ->
    describe '#parse_hostfile', ->

        it "empty file", ->
            h = new HostAdmin
            h.parse_hostfile ""

            assert.deepEqual {}, h.hosts
            assert.deepEqual {}, h.groups

        it "junk file", ->
            h = new HostAdmin
            h.parse_hostfile "
            [ 127.0.0.1 domain ]

            zombies are eating my brain

            php is the best programming language
            # wtf...
            
            "

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

        it 'parse multi times', ->
            h = new HostAdmin

            [0..10].forEach ->
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

            
        it 'host with comment and hide', ->
            h = new HostAdmin

            h.parse_hostfile """
            127.0.0.1 domain #test
            #127.0.0.1 domain #hide
            """

            assert.deepEqual h.hosts['domain'], [
                {"ip":"127.0.0.1","host":["domain"],"comment":"test","disabled":false,"line_no":0,"hide":false}
                {"ip":"127.0.0.1","host":["domain"],"comment":"","disabled":true, "line_no":1,"hide":true}
            ]

        it 'directive HIDE_ALL_OF_BELOW', ->
            h = new HostAdmin

            h.parse_hostfile """
            #HIDE_ALL_OF_BELOW
            127.0.0.1 domain
            #127.0.0.1 domain
            """

            assert.deepEqual h.hosts['domain'], [
                {"ip":"127.0.0.1","host":["domain"],"comment":"","disabled":false,"line_no":1,"hide":true}
                {"ip":"127.0.0.1","host":["domain"],"comment":"","disabled":true, "line_no":2,"hide":true}
            ]

        it 'grouping', ->

            h = new HostAdmin

            h.parse_hostfile """
            #====
            127.0.0.1 localhost1
            ##127.0.0.1 localhost2 #hide
            ##127.0.0.1 localhost3
            #====

            #
            #==== Project 1
            127.0.0.1 localhost1
            ##127.0.0.1 localhost2 #hide
            ##127.0.0.1 localhost3
            #====

            #
            #==== Project 2
            127.0.0.1 localhost1
            #127.0.0.1 localhost2
            #127.0.0.1 localhost3
            #====

            #
            #==== Project 3
            127.0.0.1 localhost1
            #127.0.0.1 localhost2
            #127.0.0.1 localhost3
            #====
            """

            assert.deepEqual h.groups, [
                {
                    name: 'Group 1'
                    hosts: [
                        {"ip":"127.0.0.1","host":["localhost1"],"comment":"","disabled":false,"line_no":1,"hide":false}
                        {"ip":"127.0.0.1","host":["localhost2"],"comment":"","disabled":true, "line_no":2,"hide":true}
                        {"ip":"127.0.0.1","host":["localhost3"],"comment":"","disabled":true, "line_no":3,"hide":false}
                    ]
                }
                {
                    name: 'Project 1'
                    hosts: [
                        {"ip":"127.0.0.1","host":["localhost1"],"comment":"","disabled":false,"line_no":8,"hide":false}
                        {"ip":"127.0.0.1","host":["localhost2"],"comment":"","disabled":true, "line_no":9,"hide":true}
                        {"ip":"127.0.0.1","host":["localhost3"],"comment":"","disabled":true, "line_no":10,"hide":false}
                    ]
                }
                {
                    name: 'Project 2'
                    hosts: [
                        {"ip":"127.0.0.1","host":["localhost1"],"comment":"","disabled":false,"line_no":15,"hide":false}
                        {"ip":"127.0.0.1","host":["localhost2"],"comment":"","disabled":true, "line_no":16,"hide":false}
                        {"ip":"127.0.0.1","host":["localhost3"],"comment":"","disabled":true, "line_no":17,"hide":false}
                    ]
                }
                {
                    name: 'Project 3'
                    hosts: [
                        {"ip":"127.0.0.1","host":["localhost1"],"comment":"","disabled":false,"line_no":22,"hide":false}
                        {"ip":"127.0.0.1","host":["localhost2"],"comment":"","disabled":true, "line_no":23,"hide":false}
                        {"ip":"127.0.0.1","host":["localhost3"],"comment":"","disabled":true, "line_no":24,"hide":false}
                    ]
                }
            ]

    describe '#host_toggle', ->
        it 'toggle on -> off', ->
            h = new HostAdmin

            h.parse_hostfile """
            127.0.0.1 domain
            #127.0.0.1 domain
            127.0.0.1 domain2
            """

            domain = h.hosts['domain'][0]
            domain2 = h.hosts['domain2'][0]

            h.host_toggle('domain', domain)

            assert.equal h.to_hostfile(), """
            #127.0.0.1 domain
            #127.0.0.1 domain
            127.0.0.1 domain2
            """
            assert.equal domain.disabled, true

            h.host_toggle('domain2', domain2)

            assert.equal h.to_hostfile(), """
            #127.0.0.1 domain
            #127.0.0.1 domain
            #127.0.0.1 domain2
            """
            assert.equal domain2.disabled, true

        it 'toggle off -> on , exclusive', ->
            h = new HostAdmin

            h.parse_hostfile """
            127.0.0.1 domain
            #127.0.0.1 domain
            #127.0.0.1 domain2
            """

            domain = h.hosts['domain'][1]
            domain2 = h.hosts['domain2'][0]

            h.host_toggle('domain', domain)

            assert.equal h.to_hostfile(), """
            #127.0.0.1 domain
            127.0.0.1 domain
            #127.0.0.1 domain2
            """
            assert.equal domain.disabled, false
            assert.equal h.hosts['domain'][0].disabled, true

            h.host_toggle('domain2', domain2)

            assert.equal h.to_hostfile(), """
            #127.0.0.1 domain
            127.0.0.1 domain
            127.0.0.1 domain2
            """
            assert.equal domain2.disabled, false

    describe '# group_toggle', ->
        it 'all enable test', ->
            h = new HostAdmin

            h.parse_hostfile """
            #==== Project 1
            127.0.0.1 localhost1
            ##127.0.0.1 localhost2 #hide
            ##127.0.0.1 localhost3
            #====

            127.0.0.1 localhost2
            127.0.0.1 localhost3

            #
            #==== Project 2
            127.0.0.1 localhost1
            127.0.0.1 localhost2 #hide
            127.0.0.1 localhost3
            #====
            """

            project1 = h.groups[0]
            project2 = h.groups[1]

            assert.equal h.group_is_all_enabled(project1), false
            assert.equal h.group_is_all_enabled(project2), true

        it 'toogle on and toggle off', ->
            h = new HostAdmin

            h.parse_hostfile """
            #==== Project 1
            127.0.0.1 localhost1
            ##127.0.0.1 localhost2 #hide
            ##127.0.0.1 localhost3
            #====

            127.0.0.1 localhost2
            127.0.0.1 localhost3

            #
            #==== Project 2
            127.0.0.1 localhost1
            127.0.0.1 localhost2 #hide
            127.0.0.1 localhost3
            #====
            """

            project1 = h.groups[0]
            project2 = h.groups[1]

            h.group_toggle(project1)

            assert.equal h.to_hostfile(), """
            #==== Project 1
            127.0.0.1 localhost1
            127.0.0.1 localhost2 #hide
            127.0.0.1 localhost3
            #====

            127.0.0.1 localhost2
            127.0.0.1 localhost3

            #
            #==== Project 2
            127.0.0.1 localhost1
            127.0.0.1 localhost2 #hide
            127.0.0.1 localhost3
            #====
            """

            assert.equal h.group_is_all_enabled(project1), true

            h.group_toggle(project2)

            assert.equal h.to_hostfile(), """
            #==== Project 1
            127.0.0.1 localhost1
            127.0.0.1 localhost2 #hide
            127.0.0.1 localhost3
            #====

            127.0.0.1 localhost2
            127.0.0.1 localhost3

            #
            #==== Project 2
            #127.0.0.1 localhost1
            #127.0.0.1 localhost2 #hide
            #127.0.0.1 localhost3
            #====
            """

            assert.equal h.group_is_all_enabled(project2), false

