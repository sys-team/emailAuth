create or replace function ea.invite(
    @email text default http_variable('email'),
    @auth text default util.HTTPVariableOrHeader('authorization')
) returns xml
begin

    declare @response xml;
    declare @author IDREF;
    declare @logXid uniqueidentifier;

    set @logXid = newid();

    insert into ea.log with auto name select
        @logXid as xid,
        'invite' as service
    ;

    set @author = ea.checkAccessToken(@auth);

    set @response = case
        when @author is null then

            xmlelement('error', xmlattributes('InvalidAccessToken' as "code"), 'Not authorized')

        when @email not regexp '.+@.+\..+' then

            xmlelement('error', xmlattributes('InvalidEmail' as "code"), 'Invalid email address')

        when exists (
            select * from ea.invite
            where email = @email -- and confirmed = 1
        ) or exists (
            select * from ea.account
            where email = @email
        ) then

            xmlelement('error', xmlattributes('EmailInUse' as "code"),'This email is already in use')

    end;

    if @response is null then

        insert into ea.invite on existing update with auto name select
            @email as email,
            @author as author,
            ea.uuuid() as code,
            0 as confirmed
        ;

        set @response = xmlelement('success', xmlattributes(@@identity as "id"));

    end if;

    update ea.log set
        response = @response
    where xid = @logXid;

    return @response;

end;
