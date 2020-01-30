Create Function fn_DSTypeValue_rpt(@SalesmanName nvarchar(4000))          
Returns @DSType Table (DSType_Value nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)          
As          
Begin          
		Declare @Delimeter char(1)
		set @Delimeter = ','

		Declare @SalesMan Table (salesman nvarchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS )


		If (@SalesmanName='%%' or @SalesmanName='%' or @SalesmanName='All')
			Insert into @DSType select distinct "dstypevalue"= dstypevalue from dstype_master dsm, dstype_details dsd where dsm.dstypeid = dsd.dstypeid and  
			dsd.salesmanid in (select salesmanid from salesman) and dsm.dstypectlpos=1		
		else
			Begin
			Insert into @SalesMan (salesman) select ItemValue from dbo.sp_SplitIn2Rows(@SalesmanName,@Delimeter)
			Insert into @DSTYpe select distinct "dstypevalue"= dstypevalue from dstype_master dsm, dstype_details dsd where dsm.dstypeid = dsd.dstypeid and  
			dsd.salesmanid in (select salesmanid from salesman where salesman_name in (select * from @Salesman)) and dsm.dstypectlpos=1		
			End
      
Return          
End  
