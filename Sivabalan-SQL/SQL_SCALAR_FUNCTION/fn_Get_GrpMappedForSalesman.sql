Create Function fn_Get_GrpMappedForSalesman(@SalesmanID Int)
Returns nVarchar(1000)
As
Begin
	declare @GrpId nvarchar(200)
	set @GrpId=''
	
	Declare @TmpGrpID table (GroupID int)

	insert into @TmpGrpID
	select distinct  cast(TDSCGM.GroupID as int) 'GroupID'
	from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM 
	on DSD.dstypeid=TDSCGM.dstypeid and DSD.SalesManid=@SalesmanID
		 

	select  @GrpId=@GrpId+cast(GroupID as nvarchar(30))+',' from @TmpGrpID

	Return (case when @GrpId='' then '' else left(@GrpId,len(@GrpId)-1) end )

end
