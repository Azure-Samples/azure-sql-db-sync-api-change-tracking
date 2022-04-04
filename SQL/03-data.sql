/*
    Insert some "pre-existing" data
*/
insert into dbo.TrainingSessions 
    (RecordedOn, [Type], Steps, Distance, Duration, Calories)
values 
    ('20211028 17:27:23 -08:00', 'Run', 3784, 5123, 32*60+3, 526),
    ('20211027 17:54:48 -08:00', 'Run', 0, 4981, 32*60+37, 480)
go

/*
    View Data
*/
select * from dbo.TrainingSessions
go

/*
    Make some changes
*/
insert into dbo.TrainingSessions 
    (RecordedOn, [Type], Steps, Distance, Duration, Calories)
values 
    ('20211026 18:24:32 -08:00', 'Run', 4866, 4562, 30*60+18, 475)
go

update 
    dbo.TrainingSessions 
set 
    Steps = 3450
where 
    Id = 13 -- Make sure to select an if returned by previous rows

/*
    Delete someting
*/
delete from dbo.TrainingSessions where Id = 12
