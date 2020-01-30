create Function fn_GetCG_Param(@CGtype nvarchar(100),@DSTypeValue nvarchar(50)='%')    
Returns @CatID Table (GroupName nvarchar(50))    
As    
Begin
IF @DSTypeValue ='%' or @DSTypeValue ='%%'
BEGIN
	If @CGtype='Operational'  
	 insert into @CatID
	 Select GroupName From productcategorygroupabstract where OCGtype = 1  and groupid in (select groupid from tbl_merp_dstypecgmapping
	where dstypeid in (select dstypeid from dstype_master where dstypevalue like @DSTypeValue))
	Else  
	insert into @CatID
	 Select GroupName From productcategorygroupabstract where GroupName in (Select distinct CategoryGroup from tblcgdivmapping) 
	 and groupid in (select groupid from tbl_merp_dstypecgmapping
	 where dstypeid in (select dstypeid from dstype_master where dstypevalue like @DSTypeValue))
END
ELSE
BEGIN
	If @CGtype='Operational'  
	 insert into @CatID
	 Select GroupName From productcategorygroupabstract where OCGtype = 1  and groupid in (select groupid from tbl_merp_dstypecgmapping
	where dstypeid in (select dstypeid from dstype_master where dstypevalue in (Select * From dbo.sp_splitIn2Rows(@DSTypeValue,','))))
	Else  
	insert into @CatID
	 Select GroupName From productcategorygroupabstract where GroupName in (Select distinct CategoryGroup from tblcgdivmapping) 
	 and groupid in (select groupid from tbl_merp_dstypecgmapping
	 where dstypeid in (select dstypeid from dstype_master where dstypevalue in (Select * From dbo.sp_splitIn2Rows(@DSTypeValue,','))))
END
Return
End    
