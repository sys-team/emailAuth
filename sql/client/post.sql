create or replace function eac.post(
    url STRING,
    cert STRING,
    access_token STRING
)
returns STRING
url '!url'
type 'HTTP:POST'
certificate '!cert'
;

