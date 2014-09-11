create or replace function ea.emailAuth(@url long varchar)
returns xml
begin
    declare @response xml;

    set @response = case @url
        when 'login' then
            ea."login"()
        when 'register' then
            ea.register()
        when 'confirm' then
            ea.confirm()
        when 'roles' then
            ea.roles()
        when 'check' then
            ea."check"()
        when 'token' then
            ea.token()
        when 'confirmInvite' then
            ea.confirmInvite()
        else
            'Unknown service request'
    end case;

    set @response = xmlelement('response', xmlattributes('https://github.com/sys-team/UOAuth' as "xmlns"), @response);

    return @response;
    
end;
