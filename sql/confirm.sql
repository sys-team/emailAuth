create or replace function ea.confirm(
    @code long varchar default isnull(nullif(replace(http_header('Authorization'), 'Bearer ', ''),''), http_variable('code')),
    @password long varchar default http_variable('password'),
    @oldPassword long varchar default  isnull(http_variable('current-password'),'')
)
returns xml
begin
    declare @response xml;
    declare @userId integer;
    declare @xid uniqueidentifier;
    declare @confimationOffset integer;
    declare @passwordOffset integer;

    set @xid = newid();

    insert into ea.log with auto name
    select @xid as xid,
           'confirm' as service;
           
    set @confimationOffset = isnull(util.getUserOption('ea.confimationOffset'), 30);
    set @passwordOffset = isnull(util.getUserOption('ea.passwordOffset'), 5);

    set @userId = coalesce((select id
                             from ea.account
                           where confirmationCode = @code
                             and confirmationTs >= dateadd(minute, -@confimationOffset, now())
                             and confirmed = 0),
                           (select id
                              from ea.account
                             where confirmationCode = @code
                               and confirmationTs >= dateadd(minute, -@passwordOffset, now())
                               and @password is not null
                               and confirmed = 1),
                            (select id
                              from ea.account
                             where authCode = @code
                               and hash(@oldPassword, 'SHA256') = password
                               and @password is not null
                               and confirmed = 1));

    if @userId is null then
        if not exists (select *
                         from ea.account
                        where confirmationCode = @code
                          and confirmationTs >= dateadd(minute, -@confimationOffset, now())
                           or authCode = @code) then
                           
            set @response = xmlelement('error',xmlattributes('InvalidCode' as "code"), 'Wrong confirmation code');
            
        elseif exists (select id
                         from ea.account
                        where confirmationCode = @code
                          and confirmationTs < dateadd(minute, -@passwordOffset, now())
                          and @password is not null
                          and confirmed = 1) then
                          
            set @response = xmlelement('error',xmlattributes('InvalidCode' as "code"), 'Wrong confirmation code');
            
        else
          
            set @response = xmlelement('error',xmlattributes('InvalidLogPass' as "code"), 'Invalid old password');
            
        end if
    else
        if @password is not null and ea.passwordCheck(@password) = 0 then
            set @response = xmlelement('error',xmlattributes('InvalidPass' as "code"),
                                              'Password must be at least 6 characters, including an uppercase letter and a special character or number');
        else
            
            update ea.account
               set confirmed = 1,
                   password = isnull(hash(@password,'SHA256'),password),
                   confirmationCode = null,
                   OTPEnabled = if isnull(util.getUserOption ('ea.OTPEnabled'), '0') = '1' then 1 else 0 endif
             where id = @userId;

            set @response = xmlconcat(
                                xmlelement('access_token', ea.newAuthCode(@userId)),
                                if isnull(util.getUserOption ('ea.OTPEnabled'), '0') = '1' then
                                    xmlelement('otp_uri', ea.OTPUri( ea.newOTPCode(@userId), @userId))
                                else
                                    ''
                                endif
                            );
        end if;
    end if;

    update ea.log
       set response = @response
     where xid = @xid;

    return @response;
end
;
