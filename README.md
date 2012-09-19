# NAME

Panky - Panky is a chatty, github, issue, and-ci helper bot for your team

# VERSION

version 0.001

# SYNOPSIS

Panky is a chatting, github, Jira, jenkins loving
web-app/bot/do-it-all/chef(?) for your team.

Panky lurks in your teams chat room (Jabber is currently supported) and provides
useful information and functionality __all day long__.

__Note: [Panky](http://search.cpan.org/perldoc?Panky) is still in active development and is not feature complete__

Currently, Panky will connect to your chat server, update you about what's
going on with your github repos (new pushes, pull request activity, comments,
etc.) and enable you to get info about them on demand.  It can also parse
`Jira` links, and provide information about (and start) `Jenkins` builds.

Panky can also use the `Github|http://github.com`
[commit status API](https://github.com/blog/1227-commit-status-api) to show
the status of your Continuous Integration builds on Pull Requests.

Some sample usage:

    > panky: gh setup repo1/user1
    # Panky sets up github hooks for itself for that repo

    # Set an alias 'alias' for user/my-repo
    > panky: gh set repo myrepo => user/my-repo
    # Link the github repo 'user/my-repo' with the jenkins job 'ci-job-name'
    > panky: ci set repo user/my-repo => ci-job-name
    # Run the 'ci-job-name' job against pull-request #1 on user/my-repo
    > panky: test my-repo pr 1

    # When a build succeeds/fails
    > <panky> [Jenkins: ci-job-name] failed https://myjenkins/job/ci-job-name/1

    # When a teammate creates a pull request (with git.io shortened url)
    > <panky> [user/my-repo] PR 'Fix the broken things' opened by throughnothing http://git.io/XXXX

    # Panky can show info about your JIRA tickets
    > hey, check out https://company.atlassian.net/brows/PROJ-1
    > <panky> [PROJ-1](Priority) assignee => Issue summary

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

## Jenkins Support

You can also give it the `URL` to your [Jenkins](http://jenkins-ci.org) server
via the `PANKY_JENKINS_URL` option.  [Panky](http://search.cpan.org/perldoc?Panky) will use this to generate
links to Jenkins builds, etc.  If you want [Panky](http://search.cpan.org/perldoc?Panky) to be able to start builds
on jenkins (from pull requests etc.) you should pass `PANKY_JENKINS_USER` and
`PANKY_JENKINS_TOKEN` for authentication.

## JIRA Support

[Panky](http://search.cpan.org/perldoc?Panky) can also work with JIRA if you have that.  You can enable JIRA support
by setting the following environment variables:

- PANKY_JIRA_URL

The url of your jira server: `https://company.atlassian.net/`

- PANKY_JIRA_USER

The username to use to authenticate with your JIRA server.

- PANKY_JIRA_PWD

The password of the user used to authenticate with your JIRA server.

## Heroku

To run [Panky](http://search.cpan.org/perldoc?Panky) in [Heroku](http://heroku.com), the easiest way is to use
the [Perloku](https://github.com/judofyr/perloku) buildpack.

    $ git clone https://github.com/throughnothing/Panky
    $ cd Panky
    $ heroku create -s cedar --buildpack http://github.com/judofyr/perloku.git
    # Optionally, if you want persistent storage across app restarts
    $ heroku addons:add heroku-postgresql(:dev)

Now your heroku app is setup and ready to receive the [Panky](http://search.cpan.org/perldoc?Panky) application.
Before you push [Panky](http://search.cpan.org/perldoc?Panky) to your app, you'll want to setup the environment
variables described above by using:

    $ heroku config:add ENVIRONMENT_VARIABLE="value"

For each config value that you wish to set.

Once all of that is set up, you can deploy the app using:

    $ git push heroku master

This will deploy your app code, install all dependencies, and run it.

If you have the PostgreSQL addon enabled, [Pany](http://search.cpan.org/perldoc?Pany) will detect the
`DATABASE_URL` environment variable present, and use the PostgreSQL server,
otherwise it falls back to sqlite storage, which will get lost whenever
you restart your app.

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