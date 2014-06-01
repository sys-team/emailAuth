create or replace function eac.authorize(
    @code STRING
)
returns xml
begin
    declare @result xml;
    declare @url STRING;
    declare @cert STRING;
    
    set @url = util.getUserOption('emailAuth.url') + '/roles';
    set @cert = 'cert=' + util.getUserOption('emailAuth.cert');
    
    set @result = eac.post(@url, @cert, @code);    
    
    return @result;


end
;