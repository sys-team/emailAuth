create global temporary table if not exists ea.log(
    
    httpBody long varchar default http_body(),
    service varchar(255),
    
    response xml,

    callerIP varchar(255) default connection_property('ClientNodeAddress'),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;

create global temporary table if not exists ea.code (

    account integer not null,
    requestXid GUID,
    code varchar(1024) not null,
    
    roles xml,
    ets datetime,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;   