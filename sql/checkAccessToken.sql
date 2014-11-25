create or replace function ea.checkAccessToken(
    @code STRING,
    @lifeTime integer default 360
)
returns integer
begin
    declare @result integer;
    
    set @result = coalesce((select id
                              from ea.account
                             where confirmed = 1
                               and authCode = @code
                               and dateadd(mi, @lifeTime, authCodeTs) > now()),
                           (select account
                              from ea.code
                             where code = @code
                               and now() between cts and ets));
                               
    return @result;
end
;