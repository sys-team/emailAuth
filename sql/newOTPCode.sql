create or replace function ea.newOTPCode(
    @userId integer
)
returns STRING
begin
    declare @code STRING;
    
    set @code = ea.uuuid();
    
    update ea.account
       set OTPSecret = @code,
           OTPEnabled = 1
     where id = @userId;
     
    return @code;

end
;