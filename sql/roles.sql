create or replace function ea.roles(
    @code STRING default http_variable('access_token')
)
returns xml
begin
    declare @response xml;
    declare @accountId integer;
    declare @xid GUID;
    
    set @xid = newid();
    
    insert into ea.log with auto name
    select @xid as xid,
           'roles' as service;
    
    set @accountId = ea.checkAccessToken(@code);
    
    if @accountId is null then
        set @response = xmlelement('error', xmlattributes('InvalidAccessToken' as "code"),'Not authorized');
    else
         set @response = xmlconcat(
            ea.accountRoles(@accountId),
            ea.accountData (@accountId)
        );
        
    end if;
    
    update ea.log
       set response = @response
     where xid = @xid;
    
    return @response;
end
;