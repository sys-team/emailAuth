emailAuth
=


check
-
### variables:

* login - login or email

### returns:

"found" or "not found" element

    <response xmlns="https://github.com/sys-team/UOAuth">
        <found/>
    </response>


confirm
-

### variables:
*code - authorization code for new user or access token for registered user
*password  - empty or new password for registered user
*current-password - empty or old password for registered user

### returns:

new access token

    <response xmlns="https://github.com/sys-team/UOAuth">
        <access_token>8c6070698abac00822b6eb62d4649adc</access_token>
    </response>

login
-

* variables:

login - login or email or empty if access token used as password

password - password or access token

* returns new access token if password supplied or access token used as password

register
-

* variables

login - login
password - password
email - email
callback - callback URL
smtp-sender - sender for confirmation message
smtp-server - server to send confirmation message from
subject - subject for donfirmation message

* returns "registered" if success
* sends email message with confirmation code

    <response xmlns="https://github.com/sys-team/UOAuth">
        <registered/>
    </response>

roles
-

* variables:

access_token - access token

* returns xml with roles

token
_

* variables:

access_token - access token

* returns new access token
