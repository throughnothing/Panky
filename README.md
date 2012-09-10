# NAME

Panky - Panky is a chatty, github-and-ci helper bot for your team

# VERSION

version 0.001

# SYNOPSIS

Panky aims to be a chatting, github and jenkins loving
web-app/bot/do-it-all/chef(?) for your team.

__Note: [Panky](http://search.cpan.org/perldoc?Panky) is still in active development and is not feature complete__

Currently, Panky will connect to your chat server, update you about what's
going on with your github repos (new pushes, pull request activity, comments,
etc.) and enable you to get info about them on demand.

In the future, Panky will be able to get Jenkins build statuses,
create builds, run builds, and report back to the chat with its findings.

Panky will not make you a sandwich (yet).

# INSTALLING

[Panky](http://search.cpan.org/perldoc?Panky) requires a non-blocking server in order to run.  This means that
you probably want to use either [Twiggy](http://search.cpan.org/perldoc?Twiggy), or the builtin [Mojolicious](http://search.cpan.org/perldoc?Mojolicious)
server.

## Environment Variables

[Panky](http://search.cpan.org/perldoc?Panky) is configured via environment variables to make it easy to install on
systems like [Heroku](http://heroku.com).

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

## Heroku

To run [Panky](http://search.cpan.org/perldoc?Panky) in [Heroku](http://heroku.com), the easiest way is to use
the [Perloku](https://github.com/judofyr/perloku) buildpack.

    $ git clone https://github.com/throughnothing/Panky
    $ cd Panky
    $ heroku create -s cedar --buildpack http://github.com/judofyr/perloku.git

Now your heroku app is setup and ready to receive the [Panky](http://search.cpan.org/perldoc?Panky) application.
Before you push [Panky](http://search.cpan.org/perldoc?Panky) to your app, you'll want to setup the environment
variables described above by using:

    $ heroku config:add ENVIRONMENT_VARIABLE="value"

For each config value that you wish to set.

Once all of that is set up, you can deploy the app using:

    $ git push heroku master

This will deploy your app code, install all dependencies, and run it.

# USAGE

Once configured and setup, [Panky](http://search.cpan.org/perldoc?Panky) is mostly interacted with via chat
(jabber by default).  Below are some commands that [Panky](http://search.cpan.org/perldoc?Panky) accepts.  In
general, these commands must be directed at the [Panky](http://search.cpan.org/perldoc?Panky) chat bot
(i.e you must mention the bot by name: "panky: COMMAND").

- gh setup _FULL_REPO_NAME_

This will direct [Panky](http://search.cpan.org/perldoc?Panky) to setup [Github](http://github.com) Hooks for the
repo in question. _FULL_REPO_NAME_ should look like `user/repo` or
`organization/repo`.  The `GITHUB_USER` that is setup for [Panky](http://search.cpan.org/perldoc?Panky) must have
access to the repo if it is private for this to work.

# AUTHOR

William Wolf <throughnothing@gmail.com>

# COPYRIGHT AND LICENSE



William Wolf has dedicated the work to the Commons by waiving all of his
or her rights to the work worldwide under copyright law and all related or
neighboring legal rights he or she had in the work, to the extent allowable by
law.

Works under CC0 do not require attribution. When citing the work, you should
not imply endorsement by the author.