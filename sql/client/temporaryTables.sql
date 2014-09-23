create global temporary table eac.code (

    code varchar(1024) not null unique,
    
    accountData xml,
    ets datetime,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;  