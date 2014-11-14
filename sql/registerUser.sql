create or replace function ea.registerUser(
    @id integer,
    @login long varchar,
    @email long varchar,
    @password long varchar,
    @requestXid GUID default null
)
returns integer
begin
    declare @result integer;
    declare @code long varchar;
    
    insert into ea.account on existing update with auto name
    select @id as id,
           @login as username,
           hash(@password,'SHA256') as password,
           @email as email,
           if isnull(util.getUserOption('ea.OTPEnabled'), '0') = '1' then 1 else 0 endif as OTPEnabled;
           
    set @result = @@identity;
    
    set @code = ea.newConfirmationCode(@result, 30, @requestXid);
    
    return @result;
end
;