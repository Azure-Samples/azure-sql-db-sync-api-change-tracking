create or alter procedure web.get_trainingsessionsync 
@json nvarchar(max)
as

declare @fromVersion int = json_value(@json, '$.fromVersion')

set xact_abort on
set transaction isolation level snapshot;  
begin tran 
    declare @reason int

    declare @curVer int = change_tracking_current_version();
    declare @minVer int = change_tracking_min_valid_version(object_id('dbo.TrainingSession'));

    if (@fromVersion = 0) begin
        set @reason = 0 -- First Sync
    end else if (@fromVersion < @minVer) begin
        set @fromVersion = 0
        set @reason = 1 -- fromVersion too old. New full sync needed
    end

    if (@fromVersion = 0)
    begin
        select
            @curVer as 'Metadata.Sync.Version',
            'Full' as 'Metadata.Sync.Type',
            @reason as 'Metadata.Sync.ReasonCode',
            [Data] = json_query((select Id, RecordedOn, [Type], Steps, Distance from dbo.TrainingSession for json auto))
        for
            json path, without_array_wrapper
    end else begin
        select
            @curVer as 'Metadata.Sync.Version',
            'Diff' as 'Metadata.Sync.Type',
            [Data] = json_query((
                select 
                    ct.SYS_CHANGE_OPERATION as '$operation',
                    ct.Id, 
                    ts.RecordedOn,
                    ts.[Type], 
                    ts.Steps, 
                    ts.Distance,
                    ts.PostProcessedOn,
                    ts.AdjustedSteps,
                    ts.AdjustedDistance
                from 
                    dbo.TrainingSession as ts 
                right outer join 
                    changetable(changes dbo.TrainingSession, @fromVersion) as ct on ct.[Id] = ts.[id]
                for 
                    json path
            ))
        for
            json path, without_array_wrapper
    end

commit tran