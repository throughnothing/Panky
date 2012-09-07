# NAME

Panky - Panky is a chatting, github, and jenkins loving web-app

# VERSION

version 0.001

# SYNOPSIS

Panky aims to be a chatting, github and jenkins loving
web-app/bot/do-it-all/chef(?).

Panky will connect to your chat server, update you about what's going
on with your github repos, and enable you to get info about them on demand.

Panky will also be able to get Jenkins build statuses, create builds, and
report back to the chat with its findings.

Panky will not make you a sandwich (yet).

# INSTALLING

The following environment variables must be set for [Panky](http://search.cpan.org/perldoc?Panky) to run:

- PANKY_BASE_URL

This should be set to the base url that the [Panky](http://search.cpan.org/perldoc?Panky) server will be running on.

- PANKY_GITHUB_USER

The username of a Github user that will have access to whatever is needed.

- PANKY_GITHUB_PWD

The Github password for the user mentioned above.

Optionally, you can also provide chat parameters to have [Panky](http://search.cpan.org/perldoc?Panky) connect to
jabber:

- PANKY_CHAT_JABBER_JID

The `jid` of [Panky](http://search.cpan.org/perldoc?Panky)'s jabber account.

- PANKY_CHAT_JABBER_PWD

The password for [Panky](http://search.cpan.org/perldoc?Panky)'s jabber account.

- PANKY_CHAT_JABBER_HOST

If you need to set your jabber host to something different than the domain
part of the `jid`, then you can use this variable to do so.

- PANKY_CHAT_JABBER_ROOM

The jabber conference room that [Panky](http://search.cpan.org/perldoc?Panky) should join.  This should be the
full `jid` of the room, such as `room@conference.jabber.server.com`.

# USAGE

# AUTHOR

William Wolf <throughnothing@gmail.com>

# COPYRIGHT AND LICENSE



William Wolf has dedicated the work to the Commons by waiving all of his
or her rights to the work worldwide under copyright law and all related or
neighboring legal rights he or she had in the work, to the extent allowable by
law.

Works under CC0 do not require attribution. When citing the work, you should
not imply endorsement by the author.