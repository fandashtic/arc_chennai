
CREATE procedure FSU_SP_insert_ReleaseDetail(                
@ReleaseID int                
,@UpdateID int            
,@FSUID int                
,@UpdateName nvarchar(100)                
,@UpdateType int                
,@TargetClient int               
,@Targettool int                
,@FullFileName nvarchar(500)                
,@FileName nvarchar(500)                
,@chkSum bigint                
,@SeverityType int                
,@SkipCount int                
,@InstallationDate datetime                
,@Message nvarchar(4000)                
,@MessageType int              
,@ScheduleFrom datetime              
,@ScheduleTo datetime              
,@Event int              
,@WDCode nvarchar(6)      
,@IsSpecific int                
,@status int=65 
,@mode int     
              
--,@CreatedUser nvarchar(50)
--@mode=1 for 'MISSING' and @mode=0 for 'CHECK'                
)                
as                
set dateformat dmy  
if @mode=1 or @mode=0
begin
if exists(select ReleaseID from tblReleaseDetail where ReleaseID=@ReleaseID) 
begin
update tblReleaseDetail set status=1 where ReleaseID in (select top 1 ReleaseID from tblReleaseDetail 
where ReleaseID=@ReleaseID)
end           
end
if not exists(select ReleaseID from tblReleaseDetail where ReleaseID=@ReleaseID)                 
begin                
-- Insert into ReleaseDetail                
insert into tblReleaseDetail(ReleaseID,UpdateID,UpdateName,UpdateType,WDCode,status)                
values(@ReleaseID,@UpdateID,@UpdateName,@UpdateType,@WDCode,@status)                
                
-- Insert into tblUpdateDetail/tblDocumentDetail/tblMessageDetail                
if @UpdateType=1 --Update                
insert into tblUpdateDetail(ReleaseID,FSUID,Targettool,TargetClient,FullFileName,FileName,chkSum,SeverityType,SkipCount,InstallationDate,IsSpecific)                
values(@ReleaseID,@FSUID,@Targettool,@TargetClient,@FullFileName,@FileName,@chkSum,@SeverityType,@SkipCount,@InstallationDate,@IsSpecific)                
                
else if @UpdateType=2 --Document                
insert into tblDocumentDetail(ReleaseID,FileName,chkSum)                
values(@ReleaseID,@FullFileName,@chkSum)                
                
else if @UpdateType=3--Message                
insert into tblMessageDetail(ReleaseID,Message,MessageType,ScheduleFrom,ScheduleTo,Event)                
values(@ReleaseID,@Message,@MessageType,@ScheduleFrom,@ScheduleTo,@Event)                
end     

SET QUOTED_IDENTIFIER OFF
