create or replace function eac.authorize(
    @code STRING
)
returns xml
begin
    declare @result xml;
    declare @url STRING;
    declare @cert STRING;
    
    set @result = (select accountData
                     from eac.code
                    where code = @code
                      and ets > now());
                    
    if @result is null then                
    
        if isnull(util.getUserOption('eac.localAuth'), '0') = '0' then
        
            set @url = util.getUserOption('emailAuth.url') + '/roles';
            set @cert = 'cert=' + util.getUserOption('emailAuth.cert');
            
            set @result = eac.post(@url, @cert, @code);
            
        else
        
            set @result = xmlelement(
                'response',
                xmlattributes('https://github.com/sys-team/UOAuth' as "xmlns"),
                ea.roles(@code)
            );
            
        end if;
        
        insert into eac.code on existing update with auto name
        select (select id
                  from eac.code
               where code = @code) as id,
               @code as code,
               @result as accountData,
               dateadd(mi, isnull(util.getUserOption('eac.tokenLifeTime'), 60), now()) as ets;
        
    end if;
    
    return @result;

end
;