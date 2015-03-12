create or replace function ea.emailAuth(
    @url STRING
)
returns xml
begin
    declare @response xml;
    declare @error STRING;
    declare @sqlstate STRING;

    begin

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
            when 'invite' then
                ea.invite()
            when 'checkOTP' then
                ea.checkOTP()
            when 'OTPSecret' then
                ea.OTPSecret()
            when 'console' then
                ea.console()
            else
                'Unknown service request'
        end;

    exception when others then
    
        set @error = errormsg();
        set @sqlstate = SQLSTATE;
        
        rollback;       
        
        call util.errorHandler('ea.emailAuth', @sqlstate, @error);
            
        set @response = xmlelement(
            'error', xmlattributes('UnknownError' as "code"), @error
        );

    end;

    set @response = xmlelement(
        'response',
        xmlattributes('https://github.com/sys-team/UOAuth' as "xmlns"),
        @response
    );

    return @response;

end;
