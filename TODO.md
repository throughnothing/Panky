# TODO

* Use CHI (with Redis) instead of DBM::Deep since the DBM::Deep files
  are lost on Heroku restart.
* Allow 'retesting' of pull requests by saying 'retest' etc...
* Github Hook Secret Signing Support (`hub.secret` on
    [Repo * Hooks](http://developer.github.com/v3/repos/hooks/))
* Make the '/' page look better (good)
* HookActor that aggregates all types of certain actions daily/weekly/monthly?
    - 'gh activity today' would maybe show PRs closed for the day, etc.
* Git Deploy/Merge Support
    - 'panky deploy blah blah blah' to deploy stuff
* Integrate with JIRA API's
