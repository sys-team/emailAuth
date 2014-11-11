create or replace function ea.checkOTP(
    @code STRING default http_variable('access_token'),   
    @OTPCode STRING default http_variable('otp_code')
)
returns xml
begin
    declare @result xml;
    declare @accountId IDREF;
    declare @OTPSecret STRING;
    
    set @accountId = coalesce((select id
                                 from ea.account
                                where confirmed = 1
                                  and authCode = @code),
                              (select account
                                 from ea.code
                                where code = @code
                                  and now() between cts and ets));
                                  
    if @accountId is not null then
    
        set @OTPSecret = (select OTPSecret
                            from ea.account
                           where id = @accountId);
                           
        if util.googleOTPCodeCheck(@OTPSecret, @OTPCode) = 1 then
            set @result = xmlelement('checked');
        else
            set @result = xmlelement('error', xmlattributes('InvalidOTP' as "code"),'Not authorized');
        end if;
    
    else
        set @result = xmlelement('error', xmlattributes('InvalidAccessToken' as "code"),'Not authorized');
    end if;

    return @result;

end
;