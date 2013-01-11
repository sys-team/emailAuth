emailAuth
============

check
------------
Checks is login or email already used

### variables:

* login - login or email

### returns:

"found" or "not found" element

    <response xmlns="https://github.com/sys-team/UOAuth">
        <found/>
    </response>


confirm
------------
Confirms new user registration or changes password for registered user

### HTTP headers:

* Authorization - "Bearer " + authorization code

### variables:

* code - authorization code for new user or access token for registered user
* password  - empty or new password for registered user
* current-password - empty or old password for registered user

### returns:

access token

    <response xmlns="https://github.com/sys-team/UOAuth">
        <access_token>8c6070698abac00822b6eb62d4649adc</access_token>
    </response>

login
------------
Logs user in by login/password or access token

###  variables:

* login - login or email or empty if access token used as password

* password - password or access token

### returns:

new access token if password supplied or access token used as password

    <response xmlns="https://github.com/sys-team/UOAuth">
        <access_token>13513aca143af1389e919dfba58b4b40</access_token>
    </response>

register
------------
Registers new user or sends new confirmation code for registered user to change password  

### variables:

* login - login
* password - password
* email - email
* callback - callback URL
* smtp-sender - sender for confirmation message
* smtp-server - server to send confirmation message from
* subject - subject for confirmation message

### returns:

"registered" element if success


sends email message with confirmation code

    <response xmlns="https://github.com/sys-team/UOAuth">
        <registered/>
    </response>

roles
------------
Returns list of user roles and user account information

### variables:

* access_token - access token

### returns:

xml with roles list and user information

    <response xmlns="https://github.com/sys-team/UOAuth">
        <roles>
            <role>
                <code>authenticated</code>
            </role>
        </roles>
        <account>
            <username>somebody</username>
            <email>somebody@somewhere.net</email>
            <id>1</id>
        </account>
    </response>

token
------------
Returns new access token with short lifetime

### variables:

* access_token - access token

### returns:

new access token

    <response xmlns="https://github.com/sys-team/UOAuth">
        <access_token>f469f52622bd58dd0ab0cf03cb147e21</access_token>
    </response>



