%{

%}

/* lexical grammar */
%lex

%%

"#===="             { if (yy.group_id++ % 2 == 0) { return 'GROUP_START'; } else { return 'GROUP_END'; } }

"#"+[ \t]*[Hh][Ii][Dd][Ee]_[Aa][Ll][Ll]_[Oo][Ff]_[Bb][Ee][Ll][Oo][Ww] { return 'HIDE_ALL_OF_BELOW';}

"#"+[ \t]*[Hh][Ii][Dd][Ee]    { return 'HIDE';}

"#"+                { return 'HASH'; }

((1?\d?\d|(2([0-4]\d|5[0-5])))\.){3}(1?\d?\d|(2([0-4]\d|5[0-5])))[ \t]+  { return 'IP';}
((([0-9A-Fa-f]{1,4}\:){7}([0-9A-Fa-f]{1,4}|\:))|(([0-9A-Fa-f]{1,4}\:){6}(\:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|\:))|(([0-9A-Fa-f]{1,4}\:){5}(((\:[0-9A-Fa-f]{1,4}){1,2})|\:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|\:))|(([0-9A-Fa-f]{1,4}\:){4}(((\:[0-9A-Fa-f]{1,4}){1,3})|((\:[0-9A-Fa-f]{1,4})?\:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|\:))|(([0-9A-Fa-f]{1,4}\:){3}(((\:[0-9A-Fa-f]{1,4}){1,4})|((\:[0-9A-Fa-f]{1,4}){0,2}\:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|\:))|(([0-9A-Fa-f]{1,4}\:){2}(((\:[0-9A-Fa-f]{1,4}){1,5})|((\:[0-9A-Fa-f]{1,4}){0,3}\:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|\:))|(([0-9A-Fa-f]{1,4}\:){1}(((\:[0-9A-Fa-f]{1,4}){1,6})|((\:[0-9A-Fa-f]{1,4}){0,4}\:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|\:))|(\:(((\:[0-9A-Fa-f]{1,4}){1,7})|((\:[0-9A-Fa-f]{1,4}){0,5}\:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|\:)))(\%.+)?[ \t]+  {return 'IP';}


[ \t]+               { ;}
\n                   { return 'LF';} 
[^ \t\n]+            { return 'WORD';}

/lex

%left WORD HASH HIDE

%% /* language grammar */

hosts
    :
    | hosts line { if(typeof($2) == 'object') { yy.hosts.push($2); yy.cur_group.hosts.push($2); } }
    | hosts group_start
    | hosts group_end
    | hosts HIDE_ALL_OF_BELOW { yy.hide_below = true; }
    ;

group_start
    : GROUP_START { yy.cur_group = { name : "", hosts : [] };}
    | group_start WORD { yy.cur_group.name += ' ' + $2; }
    | group_start LF
    ;

group_end
    : GROUP_END { 
                    var gid = yy.groups.push(yy.cur_group) - 1;

                    yy.cur_group.name = yy.cur_group.name.replace(/^\s+|\s+$/g, '');
                    if(!yy.cur_group.name) { yy.cur_group.name = "Group " + (gid + 1); } 
                    
                    yy.cur_group = yy.root_group;

                }
    | group_end WORD
    | group_end LF
    ;

line
    : mapping LF { $$ = $1 }
    | mapping_with_comment LF { $$ = $1;}
    | error LF
    ;

mapping_with_comment
    : mapping HASH { $1.comment = ''; $$ = $1;}
    | mapping_with_comment WORD { $1.comment += ' ' + $2 ; $1.comment = $1.comment.replace(/^\s+|\s+$/g, '') ; $$ = $1;}
    ;

mapping
    : IP WORD { $$ = { ip : $1.replace(/^\s+|\s+$/g, ''), host : [$2], comment : '', disabled : false, line_no : yylineno, hide : yy.hide_below }; }
    | mapping WORD { $1.host.push($2); $$ = $1; }
    | HASH mapping { $2.disabled = true; $$ = $2; }
    | mapping HIDE { $1.hide = true; $$ = $1; }
    ;

%%
