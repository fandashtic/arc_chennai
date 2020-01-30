
Create procedure FSU_sp_WriteErrorLog(
@ClientID int,
@ReleaseID int,
@InstallationID int,
@ApplicationName nvarchar(100),
@ErrorMessage nvarchar(3000),
@LogType int,
@LogDate dateTime
)					
AS

INSERT INTO tblErrorLog
(
 ApplicationName,
 ClientID,
 ReleaseID,
 InstallationID,
 ErrorMessage,
 LogType,
 CreationDate
)		 
Values (
@ApplicationName, 
@ClientID,
@ReleaseID,
@InstallationID,
@ErrorMessage ,
@LogType,
@LogDate
)
