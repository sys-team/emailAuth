create or replace function ea.console(
    @code STRING default http_variable('access_token'),
    @command STRING default http_variable('command'),
    @email STRING default http_variable('email')
)
returns xml
begin
    declare @result xml;
    declare @accountId integer;
    declare @cAccountId integer;
    
    set @accountId = coalesce((select id
                                 from ea.account
                                where confirmed = 1
                                  and authCode = @code),
                              (select account
                                 from ea.code
                                where code = @code
                                  and now() between cts and ets));
                                  
    if exists(select *
                from ea.accountRole
               where account = @accountId
                 and role = 'admin') then
                 
        set @cAccountId = (select id
                             from ea.account
                            where email = @email);
                            
        if @cAccountId is not null then
        
            case @command
                when 'reset_confirmation' then
                    
                    update ea.account
                       set confirmed = 0,
                           authCode = null
                     where id = @cAccountId;
                     
                    delete from ea.code
                     where account = @cAccountId;
                     
                    set @result = xmlelement('result', 'Ok');
                
                else
                    set @result = xmlelement('error', xmlattributes('UnknownCommand' as "code"), 'Unknown Command');
            end case;  
                  
        else
            set @result = xmlelement('error', xmlattributes('NotFound' as "code"), 'Not found');
        end if;    
    else
        set @result = xmlelement('error', xmlattributes('NotAuthorized' as "code"), 'Not authorized');
    end if;
    
    return @result;

end
;