t.string   "name",                             :null => false
t.string   "uri",                              :null => false
t.integer  "room_id"
t.datetime "created_at"
t.datetime "updated_at"
t.boolean  "enabled",        :default => true, :null => false
t.string   "hook_url"
t.integer  "github_team_id"
CREATE TABLE repositories  (
    name TEXT,
    uri TEXT,
    hook_url TEXT
);

CREATE TABLE branches  (
);

CREATE TABLE commits  (
);
