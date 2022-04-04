if user_id('DotNetWebApp') is null begin
    create user DotNetWebApp with password = 'a987REALLY#$%TRONGpa44w0rd!';
end
go

if schema_id('web') is null begin
    execute('create schema web')
end
go

grant execute on schema::web to DotNetWebApp
go

if not exists(select * from sys.sequences where [name] = 'Ids')
begin
    create sequence dbo.Ids
    as int
    start with 1;
end
go

drop table if exists dbo.TrainingSessions;
create table dbo.TrainingSessions
(
    [Id] int primary key not null default(next value for dbo.Ids),
    [RecordedOn] datetimeoffset not null,
    [Type] varchar(50) not null,
    [Steps] int not null,
    [Distance] int not null, --Meters
    [Duration] int not null, --Seconds
    [Calories] int not null,
    [PostProcessedOn] datetimeoffset null,
    [AdjustedSteps] int null,
    [AdjustedDistance] decimal(9,6) null
);
go

if not exists(select * from sys.change_tracking_databases where database_id = db_id())
begin
    alter database ct_sample 
    set change_tracking = on
    (change_retention = 30 days, auto_cleanup = on)
end
go

if not exists(select * from sys.change_tracking_tables where [object_id]=object_id('dbo.TrainingSessions'))
begin
    alter table dbo.TrainingSessions
    enable change_tracking
end
go
