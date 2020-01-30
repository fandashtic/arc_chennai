CREATE proc FSU_sp_mERP_FSUInfo(@FSUID int,               
@PatchName nVarchar(1000),               
@TargetClient int,             
@DBVersionNumber nVarchar(20),               
@BuildVersion nVarchar(20),               
@FileName nVarchar(255),               
@VersionNumber nVarchar(20),          
@DestinationFolder nVarchar(300),     
@AlternativeFolder nVarchar(300),       
@ClientID nvarchar,          
@Active int)            
as            
begin           
declare @checklist int            
 set @checklist=0           
set @checklist=(select count(*) from tbl_mERP_fileinfo where FileName=@FileName)          
if(@checklist=0)                
begin            
insert into tbl_mERP_fileinfo(FSUID,PatchName,               
TargetClient,             
DBVersionNumber,               
BuildVersion,               
FileName,               
VersionNumber,DestinationFolder,AlternativeFolder,ClientID,Active) values (@FSUID,@PatchName,               
@TargetClient,             
@DBVersionNumber,               
@BuildVersion,               
@FileName,               
@VersionNumber,@DestinationFolder,@AlternativeFolder,@ClientID,@Active)            
end          
else          
begin          
if exists(select VersionNumber from tbl_mERP_fileinfo  where FileName=@FileName)        
update tbl_mERP_fileinfo set Active=0 where FileName=@FileName and Active=1           
insert into tbl_mERP_fileinfo(FSUID,PatchName,               
TargetClient,             
DBVersionNumber,               
BuildVersion,               
DestinationFolder,      
AlternativeFolder,          
FileName,               
VersionNumber,ClientID,Active) values (@FSUID,@PatchName,               
@TargetClient,             
@DBVersionNumber,               
@BuildVersion,               
@DestinationFolder,      
@AlternativeFolder,         
@FileName,               
@VersionNumber,@ClientID,@Active)            
end          
end
