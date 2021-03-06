grant connect to ea;
grant dba to ea;

create table if not exists ea.account (

    username varchar(50) not null unique,
    password varchar(200) not null,
    email varchar(512) not null unique,
    authCode varchar(1024) null,
    confirmationCode varchar(512) null,
    confirmed integer null default 0,
    confirmationTs datetime null,
    authCodeTs datetime null,
    
    OTPSecret STRING,
    OTPEnabled integer default 0,

    lastLogin datetime null,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

)
;
comment on table ea.account is 'Учетная запись пользователя'
;


create table if not exists ea.invite (

    email varchar(512) not null unique,
    code varchar(1024) null,

    not null foreign key (author) references ea.account,

    confirmed BOOL,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

)
;
comment on table ea.account is 'Приглашение стать пользователем'
;

create table if not exists ea.accountRole (

    account IDREF, 

    not null foreign key (account) references ea.account on delete cascade,
    role varchar(512) not null,

    unique (account, role),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

)
;
comment on table ea.account is 'Роль пользователя'
;
