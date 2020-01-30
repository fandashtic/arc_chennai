create Procedure FSU_SP_UpdateClientInfo(      
@MachineID Nvarchar(50),      
@MacId NVarchar(4000),      
@SystemName Nvarchar(100),      
@OsVersion NvarChar(100),      
@OsUserName Nvarchar(100),      
@PrimaryMemSize  NVarchar(100),       
@HardDiskFreeSpace Nvarchar(100),       
@ProcessorName NVarchar(100),      
@DBVersion NVarchar(100),      
@DBSize NVarchar(100),      
@IsServer int,  
@Nodevalue nvarchar(50)  
 )      
as          
Declare @ClientID Int       
Declare @Delimeter nvarchar(1)    
Declare @MacAdd nvarchar(200)    
Declare @iCount int    
Declare @iMaxClnID int    
Declare @tempCln table (clientID Int)    
Set @Delimeter = '|'    
Declare @temp table (RowId Int Identity(1, 1), MacId nvarchar(200) )    
set @MacID = ltrim(rtrim(@MacID))    
  
--We found the specific scenario in ITC169 DB. In which clientID is repeated for a Server and we are handling this issue for all Client ID  
Delete from tblclientmaster where clientid in (select clientid from tblclientmaster group by clientid having count(isnull(clientid,0)) > 1)  

/*Since we are not considering Machine ID or Mac ID anymore, we are comparing system Name instead*/
  
--set @ClientID =0    
--If @MachineID ='00000000-0000-0000-0000-000000000000' OR @MachineID ='FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF' OR Isnull(@MachineID,'') =''     
--Begin      
	--If(Isnull(@MacID,'') ='')      
	--Begin      
--		Select @ClientID = isnull(Max(ClientID), 0) from tblClientMaster where SystemName = @SystemName      
--	End      
--	Else      
--	Begin      
--		Select @ClientID = isnull(Max(ClientID), 0) from tblClientMaster where MacID in     
--		(SELECT Itemvalue from dbo.sp_SplitIn2Rows( @MacID, @Delimeter ) )    
--	End      
--end       
--Else      
--Begin      
	Select @ClientID = isnull(Max(ClientID), 0) from tblClientMaster where SystemName = @SystemName         
--end       


  
Insert into @temp SELECT Itemvalue from dbo.sp_SplitIn2Rows( @MacID, @Delimeter )    
Select top 1 @MacAdd = MacId from @temp order by RowId desc    
if @IsServer = 1     
begin    
	Insert into @tempCln SELECT clientID from tblClientMaster where IsServer = 1    
	select @iCount = count(*) from @tempCln    
	if @iCount > 1    
	begin    
		select @iMaxClnID = max(ClientID) from @tempCln    
		delete from tblClientMaster where ClientID <> @iMaxClnID and IsServer = 1     
		--To remove unwanted server entries which are having Node as Server.
		delete from tblclientmaster where IsServer <> 1 and isnull(Node,'') ='Server'
		update IND set ClientID = @iMaxClnID from tblInstallationDetail IND     
		inner join @tempCln tmp on IND.ClientID = tmp.ClientID    
		update EL set ClientID = @iMaxClnID from tblErrorLog EL     
		inner join @tempCln tmp on EL.ClientID = tmp.ClientID    
	End    
	select @ClientID = isnull(max(clientID),0) from tblClientMaster where IsServer = 1    
End    

if isnull(@ClientID, 0) = 0      
begin       
	Insert into tblClientMaster     
	(MachineID,MacId,SystemName,OsVersion,OsUserName,PrimaryMemSize,HardDiskFreeSpace,ProcessorName,DBVersion,DBSize,IsServer)      
	values (@MachineID,@MacAdd,@SystemName,@OsVersion,@OsUserName,@PrimaryMemSize,@HardDiskFreeSpace,@ProcessorName,@DBVersion,@DBSize,@IsServer)       
	set @ClientID = @@identity   
	--To update the Node value  
	update tblClientMaster set modifieddate=getdate(),node=(case when isnull(isserver,0)=1 then'Server' else 'client'+ cast(@ClientID as varchar)end)  
	where clientid=@ClientID  
	if(@IsServer = 0)    
	Begin    
		  Insert into tblInstallationDetail    
		  (ClientID ,ReleaseID ,SeverityType ,FSUID ,FileName ,Mode ,Targettool ,MaxSkip ,InstallationDate,Status)      
		  Select Distinct @ClientID, IND.ReleaseID,IND.SeverityType,IND.FSUID,IND.FileName,IND.Mode,IND.Targettool,IND.MaxSkip,IND.InstallationDate,0 From    
		  tblInstallationDetail IND     
		  Inner join tblReleaseDetail RD on IND.ReleaseID =  RD.ReleaseID    
		  inner join tblUpdateDetail UD  on UD.ReleaseID = RD.ReleaseID    
		  inner join tblClientMaster CM on IND.ClientID = CM.ClientID    
		  where IND.Status & 4 = 4     
		  And UD.TargetClient = 2    
		  And IND.Mode = 2    
		  And CM.Isserver = 1    
	End    
 
end      
if @ClientID > 0       
Begin      
 Update tblClientMaster set       
 MachineID = @MachineID    
 ,MacId =@MacAdd      
 ,SystemName=@SystemName      
 ,OsVersion=@OsVersion      
 ,OsUserName=@OsUserName      
 ,PrimaryMemSize=@PrimaryMemSize      
 ,ProcessorName=@ProcessorName      
 ,HardDiskFreeSpace=@HardDiskFreeSpace      
 ,DBVersion=@DBVersion      
 ,DBSize=@DBSize      
 ,IsServer=@IsServer      
 ,ModifiedDate =getDate()      
 ,ModifiedUser = host_name() + ' - ' + suser_sname()      
 ,ModifiedApplication = app_name()      
 where ClientID = @ClientID      
 and      
 (       
 SystemName <> @SystemName or      
 OsVersion <> @OsVersion or      
 OsUserName <> @OsUserName  or      
 PrimaryMemSize <> @PrimaryMemSize or      
 HardDiskFreeSpace <> @HardDiskFreeSpace or      
 DBVersion <> @DBVersion or       
 DBSize <> @DBSize Or      
 IsServer<>@IsServer      
 )      
 --To update the Node value  
 update tblClientMaster set modifieddate=getdate(),node=(case when isnull(isserver,0)=1 then'Server' else 'client'+ cast(@ClientID as varchar) end) where clientid=@ClientID End    
  
if ((Select isnull(ProcessorName,'') from tblclientmaster  where isserver = 1) <> @ProcessorName)
BEGIN
update tblclientmaster  set  ProcessorName = @ProcessorName where isserver = 1
END

if((Select isnull(isserver,0) from tblclientmaster where clientid = @ClientID) = 1)  
BEGIN  
update tblclientmaster set node = 'Server' where clientid = @ClientID  
--To update Server ClientMaster id in TblInstallationdetail for the latest version 
update tblinstallationdetail set clientid=(Select Top 1 clientid from tblclientmaster where isnull(isserver,0) = 1)	
where fsuid in (select distinct fsuid from tbl_merp_fileinfo)
END  
/* To update ClientID in tblinstallationdetail table as current Server ID for the FSUs installed 
after Build FSU for 6.2.0 */

update tblinstallationdetail set clientid=(Select Top 1 clientid from tblclientmaster where isnull(isserver,0) = 1)
where fsuid not in (select distinct isnull(fsuid,0) from tbl_merp_fileinfo)
And FSUID >= 4231

-- If tblclientmaster has same machine ID then node value is not created. 
-- It is handled below
-- ITC086 DB has this scenario
	select @nodevalue =isnull(node,'') from tblclientmaster where clientid = @ClientID  
	exec FSU_sp_getClientID @MachineID, @nodevalue 
