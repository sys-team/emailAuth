create or replace function ea.checkBruteforce(
    @service STRING,
    @code STRING default http_variable('access_token'),   
    @interval integer default isnull(util.getUserOption('ea.bruteForceInterval'), 60),
    @attempt integer default isnull(util.getUserOption('ea.bruteForceAttempt'), 10)
)
returns integer
begin
    declare @result integer;
    declare @deleteToken integer;
    
    set @deleteToken = 0;

    case @service
        when 'checkOTP' then
            if (select count(*)
                  from ea.failedRequest
                 where service = @service
                   and code = @code
                   and datediff(ss, ts, now()) < @interval) >= @attempt then
            
                set @result = 0;
                set @deleteToken = 1;
            
            else 
                set @result = 1;
            end if;
            
        else
            set @result = 1;
    end case;
    
    if @deleteToken = 1 then
    
        update ea.account
           set authCode = null
         where authCode = @code;
         
        delete from ea.code
         where code = @code;
         
    end if;
    
    return @result;
    
end
;