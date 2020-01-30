Create  Procedure FSU_SP_UpdateRepeatedFSUStatus(  
@InstallationID int,
@INDStatus int,
@RDStatus int)
As
Declare @ClientID int
Declare @FSUID int
Declare @IsServer int
Declare @temp table (InstallationID Int , ReleaseID int )
select  @ClientID= ClientID , @FSUID = FSUID from tblInstallationDetail where InstallationId = @InstallationID
select @IsServer = IsServer from tblClientMaster where ClientID = @ClientID
Insert @temp select InstallationID , isnull(ReleaseID,0) from tblInstallationDetail 
	where FSUID= @FSUID 
	and ClientID = @ClientID 
	and Status & 4 = 0

-- Updating status 
update IND set Status = Status | @INDStatus , DateofInstallation = getdate()
	from tblInstallationDetail IND inner join @temp tmp on tmp.installationID = IND.InstallationID
-- resetting status
update IND set Status = Status ^ 16
	from tblInstallationDetail IND inner join @temp tmp on tmp.installationID = IND.InstallationID
	where Status & 16 = 16
update IND set Status = Status ^ 8
	from tblInstallationDetail IND inner join @temp tmp on tmp.installationID = IND.InstallationID
	where Status & 8 = 8
-- Record log
Insert tblErrorLog (ClientID,InstallationID,ApplicationName,ErrorMessage,LogType) 
select @ClientID, tmp.InstallationID,'UpdateRepeatedFSUStatus','Status updated due to repeated installation of same FSU',1 from @temp tmp
-- update Releasetable status
if @IsServer = 1 
begin
	Update RD set Status = Status | @RDStatus from tblReleaseDetail RD inner join @temp tmp on tmp.releaseID = RD.releaseID
-- resetting update to server status
	Update RD set Status = Status ^ 64 from tblReleaseDetail RD inner join @temp tmp on tmp.releaseID = RD.releaseID 
	Where Status & 64 = 64
end
