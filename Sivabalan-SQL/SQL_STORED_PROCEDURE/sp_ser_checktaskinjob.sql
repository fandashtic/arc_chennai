CREATE Procedure sp_ser_checktaskinjob(@JobId as nVarchar(50), @TaskId as nvarchar(50))
as
Declare @Count Int  
Select @Count = Count(*) from Job_Tasks Where TaskID = @TaskID and JobID = @JobID
Select @Count 'Count'

