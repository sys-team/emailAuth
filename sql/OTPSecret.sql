create or replace function ea.OTPSecret(
    @code STRING default http_variable('code')
)
returns xml
begin
    declare @result xml;
    declare @xid GUID;
    declare @userId integer;
    declare @secret STRING;
    
    set @xid = newid();
    
    insert into ea.log with auto name
    select @xid as xid,
           'OTPSecret' as service;
    
    set @userId = (select id
                     from ea.account
                    where confirmationCode = @code
                      and confirmed = 0);
                      
    if @userId is not null then
        set @result = xmlelement('otp_uri', ea.OTPUri(ea.newOTPSecret(@userId), @userId));
    else
        set @result = xmlelement('error', xmlattributes('InvalidCode' as "code"), 'Wrong confirmation code');
    end if;
    
    update ea.log
       set response = @result
     where xid = @xid;
    
    return @result;
    
end
;