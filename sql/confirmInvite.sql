create or replace function ea.confirmInvite(
    @code text default http_variable('code'),
    @login text default http_variable('login'),
    @password text default http_variable('password')
) returns xml
begin

    declare @response xml;
    declare @inviteId integer;
    declare @logXid uniqueidentifier;

    set @logXid = newid();

    insert into ea.log with auto name select
        @logXid as xid,
        'confirmInvite' as service
    ;

    set @response = case
        when not exists (
            select * from ea.invite
            where code = @code
        ) then

            xmlelement('error',xmlattributes('InvalidCode' as "code"), 'Wrong invitation code')

        when exists (
            select * from ea.invite
            where code = @code and confirmed = 1
        ) then

            xmlelement('error',xmlattributes('AlreadyUsedCode' as "code"), 'Invitation code already used')

        when exists (
            select * from ea.account
            where userName = @login
        ) then

            xmlelement('error',xmlattributes('LoginInUse' as "code"), 'Login already used')

        when @login is null or ea.usernameCheck (@login) = 0 then

            xmlelement('error', xmlattributes('InvalidLogin' as "code"),
                'Login must be at least 3, maximum 15 character in length'
                + ' and contains only alphanumeric, underscore and dash characters or use email as login'
            )

        when @password is null or ea.passwordCheck (@password) = 0 then
            xmlelement('error', xmlattributes('InvalidPass' as "code"),
                'Password must be at least 6 characters, including an uppercase letter and a special character or number'
            )
    end;

    if @response is null then

        set @inviteId = (
            select id
            from ea.invite
            where code = @code and confirmed = 0
        );

        if @inviteId is null then

            set @response = xmlelement('error',xmlattributes('InvitationConfirmationErrorUnknown' as "code"),
                'Unknown invitation confirmation error'
            )

        else

            insert into ea.account on existing update with auto name select
                @login as username,
                hash(@password,'SHA256') as password,
                email,
                1 as confirmed,
                now() as confirmationTs
            from
                ea.invite
            where
                id = @inviteId
            ;

            set @response = xmlelement('access_token', ea.newAuthCode(@@IDENTITY));

            update ea.invite set
                confirmed = 1
            where id = @inviteId;

        end if;

    end if;

    update ea.log set
        response = @response
    where xid = @logXid;

    return @response;

end;
