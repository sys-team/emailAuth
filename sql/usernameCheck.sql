create or replace function ea.usernameCheck(@value text)
    returns integer
begin

    return (
        if (@value not regexp '[[:alnum:].\-_]{3,15}'
                or @value not regexp '[[:ascii:]]+'
            ) and @value not regexp '.+@.+\..+'
        then 0 else 1
    endif)

end;
