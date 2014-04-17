create or replace function ea."check"(
    @login long varchar default lower(http_variable('login'))
)
returns xml
begin
    declare @response xml;
    declare @xid GUID;
    
    set @xid = newid();
    
    insert into ea.log with auto name
    select @xid as xid,
           'check' as service;
    
    if exists(select *
                from ea.account
               where (username = @login
                  or email = @login)
                 and confirmed = 1) then
        set @response = xmlelement('found');
    else
        set @response = xmlelement('not-found');
    end if;
    
    update ea.log
       set response = @response
     where xid = @xid;
    
    return @response;
end
;