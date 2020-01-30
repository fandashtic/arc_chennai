Create Procedure mERP_SP_ListExistingQuo(@CustomerID as nvarchar(100),@FromDate as datetime,@Todate as datetime,@ItemCode as nvarchar(100),@Type as int,@QuoID as int)
As
Declare @QuotationID as int
Declare @QuotationLevel as int
Declare @Flag as int
Declare @CategoryID as int
Declare @Category_name as nVarchar(100)
Begin

	Create table #tempCategory(CategoryID int,Status int)
	declare Cur_Quo Cursor for 
	select QA.QuotationID,QA.QuotationLevel 
    from QuotationAbstract QA,QuotationCustomers QC
	where QA.QuotationID=QC.QuotationID
	and QA.QuotationID<>@QuoID
	and QC.CustomerID=@CustomerID
	and QA.Active=1	
-- /*and ((dbo.stripdatefromtime(QA.ValidFromdate) between dbo.stripdatefromtime(@FromDate) and dbo.stripdatefromtime(@Todate)) or   
--    (dbo.stripdatefromtime(QA.ValidTOdate) between dbo.stripdatefromtime(@FromDate) and dbo.stripdatefromtime(@Todate)))*/  
 and ((dbo.stripdatefromtime(@FromDate) between dbo.stripdatefromtime(QA.ValidFromdate) and dbo.stripdatefromtime(QA.ValidTOdate)) or   
    (dbo.stripdatefromtime(@Todate) between dbo.stripdatefromtime(QA.ValidFromdate) and dbo.stripdatefromtime(QA.ValidTOdate)))   
    Open Cur_Quo              
	Fetch From Cur_Quo into @QuotationID,@QuotationLevel  
    Set @Flag=0	         
	While @@fetch_status = 0
    Begin
        If @QuotationLevel=1 
        Begin
			if @Type=1 
            Begin 
				if Exists(select * from QuotationItems where QuotationID=@QuotationID  and  Product_Code=@ItemCode)
				Begin
					Set @Flag=1 
					Goto Finish
				End				
            End
            Else if @Type=2
            Begin
			   Exec dbo.GetLeafCategories '%',@ItemCode	
               if Exists (select Items.Product_Code from Items,QuotationItems QA1 where Active=1 and CategoryID in (select CategoryID from #tempCategory) and Items.Product_Code=QA1.Product_Code  and QA1.QuotationID=@QuotationID)
   		       Begin                  
				   Set @Flag=1 
				   Goto Finish				 
               End  			  
            End
        End
		Else if @QuotationLevel=2 
		Begin
             if @Type=1                			                
             Begin
				  Declare Cur_QuoCat Cursor for select MfrCategoryID from QuotationMfrCategory where QuotationID=@QuotationID
				  Open Cur_QuoCat              
				  Fetch From Cur_QuoCat into @CategoryID
				  While @@FETCH_STATUS=0
				  Begin                    
					  select @Category_name=Category_Name from ItemCategories where CategoryID=@CategoryID
					  Exec dbo.GetLeafCategories '%',@Category_name
					  if Exists (select Product_Code from Items where Active=1  and CategoryID in (select CategoryID from #tempCategory) and Product_Code=@ItemCode)
					  Begin
						  Set @Flag=1 
						  Goto Finish2
					  End 
					  Truncate table #tempCategory
					  Fetch From Cur_QuoCat into @CategoryID
				  End        		   
		Finish2:
			Close Cur_QuoCat
            Deallocate Cur_QuoCat
            Goto Finish 
           End
           Else if @Type=2
           Begin
				--select @Category_name=Category_Name from ItemCategories where CategoryID=@CategoryID
				Exec dbo.GetLeafCategories '%',@ItemCode
                if Exists(select * from QuotationMfrCategory_LeafLevel,#tempCategory where QuotationID=@QuotationID  and 
                MfrCategoryID=CategoryID)
				Begin
					Set @Flag=1 
					Goto Finish
				End
           End 
        End
		Fetch From Cur_Quo into @QuotationID,@QuotationLevel  
    End
Finish: 	
    CLose Cur_Quo
    Deallocate Cur_Quo	
    if @Flag=1 
       Select 1
    else
       Select 0
End
