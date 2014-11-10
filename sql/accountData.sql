create or replace function ea.accountData (@accountId integer)
returns xml
begin
    declare @result xml;
    
    set @result = ( select xmlelement('account', xmlforest( username, email, id),
                                     if OTPEnabled = 1 then
                                        xmlelement('otp_uri', ea.OTPUri(OTPSecret, id))
                                     else
                                        ''
                                     endif)
                      from ea.account
                     where id = @accountId);
 
    return @result;
end;