insert into dbo.TrainingSession 
    (RecordedOn, [Type], Steps, Distance, Duration, Calories)
values 
    ('20191028 17:27:23 -08:00', 'Run', 3784, 5123, 32*60+3, 526),
    ('20191027 17:54:48 -08:00', 'Run', 0, 4981, 32*60+37, 480)
go

insert into dbo.TrainingSession 
    (RecordedOn, [Type], Steps, Distance, Duration, Calories)
values 
    ('20191026 18:24:32 -08:00', 'Run', 4866, 4562, 30*60+18, 475)
go

update 
    dbo.TrainingSession 
set 
    Steps = 3450
where 
    Id = 10
