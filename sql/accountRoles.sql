create or replace function ea.accountRoles(
    @accountId IDREF
) returns xml
begin

    declare @result xml;

    set @result = (
        select xmlelement('roles',
            xmlelement('role',xmlelement('code','authenticated')),
            (select xmlagg(xmlelement('role',xmlelement('code',ar.role)))
                from ea.accountRole ar
                where account = account.id
            )
        )
        from ea.account
        where id = @accountId
    );

    return @result;

end;
