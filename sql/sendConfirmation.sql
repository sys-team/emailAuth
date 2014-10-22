create or replace procedure ea.sendConfirmation(
    @userId integer,
    @callback long varchar default null,
    @smtpSender long varchar default null,
    @smtpServer long varchar default null,
    @subject long varchar default util.getUserOption('ea.confirmationSubject')
)
begin

    declare @email long varchar;
    declare @code long varchar;
    declare @msg long varchar;
    declare @addChar varchar(24);
    
    set @addChar = if locate(@callback,'?') <> 0 then '&' else '?' endif;
    
    select email,
           confirmationCode
      into @email, @code
      from ea.account where id = @userId;
      
    if  util.getUserOption('ea.confirmationMessage') is null then

        set @msg = xmlconcat(
            xmlelement('p',
                xmlelement('span','Code: ' + @code)),
            if @callback is not null then
                xmlelement('p',
                    xmlelement('span', @callback + @addChar + 'code=' + @code))
            else
                null
            endif);
    
    else
    
        set @msg = replace(replace(util.getUserOption('ea.confirmationMessage'), '@code', @code), '@callback', @callback + @addChar + 'code=' + @code);
        
    end if;

    set @subject = isnull(@subject, @smtpSender + ' confirmation');
    
    if @smtpSender is null then
        call util.email(@email, @subject, @msg);
    else
        call util.email(@email, @subject, @msg, @smtpSender, @smtpServer);
    end if;

end
;
