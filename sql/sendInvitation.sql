create or replace procedure ea.sendInvitation(
    @invite IDREF,
    @callback long varchar default null,
    @smtpSender long varchar default 'EmailAuth',
    @smtpServer long varchar default null,
    @subject long varchar default @smtpSender + ' invitation'
)
begin

    declare @msg xml;
    declare @addChar varchar(24);

    set @addChar = if locate(@callback,'?') <> 0 then '&' else '?' endif;

    for sending as msg cursor for
        select
            invite.email as "@email", invite.code as "@code", author.username as "@author"
        from ea.invite
            join ea.account author
            on author.id = invite.author
        where invite.id = @invite
    do
        set @msg = xmlconcat(
            xmlelement ('p', @author + ' invites you to join!'),
            xmlelement ('p',
                xmlelement ('span','Follow this link to proceed: '),
                xmlelement ('a', xmlattributes(@callback + @addChar + 'code=' + @code as "href"), @callback)
            )
        );

        if @smtpServer is not null then
            call util.email(@email, @subject, @msg, @smtpSender, @smtpServer)
        end if;

        message 'ea.sendInvitation to ', @email, ': ', @msg
            to client
        ;

    end for;

end;
