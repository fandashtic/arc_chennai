Create Procedure mERP_sp_get_Versionmismatchdetails @Filname nvarchar(max),@Fileversion nvarchar(max)
AS
BEGIN
--To store the maxmium version of the file
declare @maxid bigint
--Temproary Table to Store the result
Create Table #finalresult ([ComponentName] nvarchar(max)COLLATE SQL_Latin1_General_CP1_CI_AS,Version nvarchar(20)COLLATE SQL_Latin1_General_CP1_CI_AS,updateName nvarchar(max)COLLATE SQL_Latin1_General_CP1_CI_AS,[FSU ID] nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS)
--select @maxid =  max(cast(replace(isnull(VersionNumber,''),'.','')as int)) from tbl_merp_fileinfo where isnull(FileName,'') = @Filname

Create Table #distinctresult ([ComponentName] nvarchar(max)COLLATE SQL_Latin1_General_CP1_CI_AS,Version nvarchar(20)COLLATE SQL_Latin1_General_CP1_CI_AS,updateName nvarchar(max)COLLATE SQL_Latin1_General_CP1_CI_AS,[FSU ID] nvarchar(25)COLLATE SQL_Latin1_General_CP1_CI_AS)
select @maxid =  max(cast(replace(isnull(VersionNumber,''),'.','')as bigint)) from tbl_merp_fileinfo where isnull(FileName,'') = @Filname

--If maxmimum id is not active then show error
if((Select top 1 isnull(active,0) from tbl_merp_fileinfo where isnull(FileName,'') = @Filname
and cast(replace(isnull(VersionNumber,''),'.','')as bigint) = @maxid order by creationtime desc)=0)
Begin
insert into #finalresult ([FSU ID], [ComponentName],Version,updateName)
select isnull(cast([FSUID]as varchar),'Build'), filename,VersionNumber,isnull(PatchName,'Build') from tbl_merp_fileinfo where FileName=@Filname
and cast(replace(isnull(VersionNumber,''),'.','')as bigint) = @maxid
End


--If maximum id is active but that is not matching with installation path file version, then also show error
if((Select max(cast(replace(isnull(VersionNumber,''),'.','')as bigint)) from tbl_merp_fileinfo
where isnull(FileName,'') = @Filname and isnull(active,0) = 1)<> cast(replace(isnull(@Fileversion,''),'.','')as int))
Begin
insert into #finalresult ([FSU ID], [ComponentName],Version,updateName)
select isnull(cast([FSUID]as varchar),'Build'), filename,VersionNumber,isnull(PatchName,'Build') from tbl_merp_fileinfo where FileName=@Filname and isnull(active,0) = 1
and cast(replace(isnull(VersionNumber,''),'.','')as bigint) = @maxid
End

insert into #distinctresult ([FSU ID], [ComponentName],Version,updateName)
Select distinct [FSU ID], [ComponentName],Version,updateName from #finalresult  where updatename <> [FSU ID]

select * from #distinctresult
drop table #finalresult
drop table #distinctresult
END
