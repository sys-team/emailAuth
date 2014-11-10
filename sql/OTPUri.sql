create or replace function ea.OTPUri(
    @secret STRING,
    @userId  integer
)
returns STRING
begin
    declare @result STRING;
    declare @serviceName STRING;
    
    set @serviceName = isnull(util.getUserOption('ea.OPTName'), 'emailAuth');
    
    set @result = util.googleOTPUri(@serviceName + ':' + cast(@userId as varchar(24)), @secret, 'issuer=' + @serviceName);    
    
    return @result;
    
end
;