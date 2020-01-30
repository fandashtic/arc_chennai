Create Procedure mERP_Sp_ProcessmarginDetail (@ID int)
As
Declare @CategoryName nVarchar(255)
Declare @CategoryLevel int
Declare @Percentage Decimal(18,6)
Declare @MarginDate  datetime
Declare @Type nVarchar(255)
Declare @KeyValue nVarchar(255)
Declare @SlNo int
Declare @DocumentDate datetime
Declare @OldMargin Decimal(18,6)
Declare @Errmessage nVarchar(4000)
Declare @ErrStatus int
Declare @marginAbsID int

Declare @GRNDate datetime
Declare @ProdHierarchy nVarchar(255)
Declare @GRNID int

Declare @MaxID int
Declare @CatID int
Declare @OldmarginDate datetime
Declare @Flag int 
Set Dateformat dmy

Declare @Tempdate datetime
Set @Tempdate = '31/12/1899'  

Declare @CategoryID nVarchar(255)
Declare @tmpCatName nVarchar(255)
Declare @ItemCategoryID NVarchar(255)
Declare @ProcessItmCnt int

Set @ErrStatus = 0
Set @ProcessItmCnt = 0 

Select @DocumentDate = ReceivedDate from tbl_mERP_RecdMarginAbstract where ID = @ID 

-- Begin: Process Abstract table Insert
Insert Into tbl_mERP_MarginAbstract(DocumentDate, ReceiveDocID)
Values(@DocumentDate,@ID)
Set @marginAbsID =  @@identity
-- end: Process Abstract table Insert

Create table #tempCategory(CategoryID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Status int)
Create table #TmpGRN(GRNID int)
CREATE TABLE #TmpChannelMargin(ID int,[RecdID] [Int],[RecdDetID] Int,
[ChannelTypeCode] [nvarchar](15)  COLLATE SQL_Latin1_General_CP1_CI_AS,
[RegFlag] [nvarchar](30)  COLLATE SQL_Latin1_General_CP1_CI_AS,
[CategoryName] [nvarchar](255)  COLLATE SQL_Latin1_General_CP1_CI_AS,
[Categorylevel] [Int],[MarginPercentage] [Decimal](18, 6)) 

Declare MarginCursor Cursor for 
Select  CategoryName, Categorylevel, Isnull(Percentage,0), MarginDate, Type, ID from tbl_mERP_RecdMarginDetail
where RecdID = @ID and IsNull(Status,0) = 0

Open marginCursor 
Fetch From marginCursor Into @CategoryName,  @CategoryLevel,  @Percentage , @MarginDate, @Type, @SlNo 

While @@Fetch_Status = 0  
Begin 

Set @ErrStatus = 0
Set @Flag = 0
Set @tmpCatName = ''
Set @GRNDate = ''
Set @CategoryID = ''

If (Isnull(Convert(datetime, @MarginDate, 103),'') <= @Tempdate)
Begin
	Set @Errmessage = 'MarginDate should not be Null'
	Set @ErrStatus = 1
	Goto last
End


If (Isnull(@CategoryName,'') = '')
Begin
	Set @Errmessage = 'CategoryName should not be Null'
	Set @ErrStatus = 1
	Goto last
End

If (IsNull(@CategoryLevel,0) > 5)
Begin
	Set @Errmessage = 'CategoryLevel should not be greater than five'
	Set @ErrStatus = 1
	Goto last
End

If (upper(@Type) <> 'REVOKE')
Begin
	If ((IsNull(@Percentage,0) <= 0) Or (IsNull(@Percentage,0) > 100)) 
	Begin
		Set @Errmessage = 'Percentage should not be Lesser/Equal than Zero and greater than 100'
		Set @ErrStatus = 1
		Goto last
	End
End

If (IsNull(@Type,'') = '')
Begin
	Set @Errmessage = 'Type  should not be Null Value'
	Set @ErrStatus = 1
	Goto last
End

If Not (upper(@Type) = 'MARGIN' Or upper(@Type) = 'REVOKE')
Begin
	Set @Errmessage = 'Type Value should be Margin/Revoke'
	Set @ErrStatus = 1
	Goto last
End

--If (upper(@Type) = 'REVOKE') and IsNull(@Percentage,0) > 0
--Begin
--	Set @Errmessage = 'If Type Value is Revoke then Percentage should not be given'
--	Set @ErrStatus = 1
--	Goto last
--End

If ( Select Count(*) from itemCategories where Category_Name  = @CategoryName and level = 1) =1
Begin
	If (IsNull(@CategoryLevel,0)) <> 1
	Begin
		Set @Errmessage = 'If Category is Company then Level should  be 1'
		Set @ErrStatus = 1
		Goto last
	End	
	Else
	Begin
		Set @tmpCatName = 'Company'
		Set @CategoryID = ''
		Select @CategoryID = Convert(nVarchar , CategoryID) COLLATE SQL_Latin1_General_CP1_CI_AS from ItemCategories where Category_Name  = @CategoryName 
	End
End

else If ( Select Count(*) from itemCategories where Category_Name  = @CategoryName and level = 2) =1
Begin
	If (IsNull(@CategoryLevel,0)) <> 2
	Begin
		Set @Errmessage = 'If Category is Division then Level should  be 2'
		Set @ErrStatus = 1
		Goto last
	End	
	Else
	Begin
		Set @tmpCatName = 'Division'
		Set @CategoryID = ''
		Select @CategoryID = Convert(nVarchar, CategoryID) COLLATE SQL_Latin1_General_CP1_CI_AS from ItemCategories where Category_Name  = @CategoryName 
	End
End
Else If ( Select Count(*) from itemCategories where Category_Name = @CategoryName and level = 3) =1
Begin
	If (IsNull(@CategoryLevel,0)) <> 3
	Begin
		Set @Errmessage = 'If Category is SubCategory then Level Should  be 3'
		Set @ErrStatus = 1
		Goto last
	End	
	Else
	Begin
		Set @tmpCatName = 'Sub_Category'
		Set @CategoryID = ''
		Select @CategoryID = Convert(nVarchar, CategoryID) from ItemCategories where Category_Name  = @CategoryName 
	End
End
Else If ( Select Count(*) from itemCategories where Category_Name = @CategoryName and level = 4) =1
Begin
	If (IsNull(@CategoryLevel,0)) <> 4
	Begin
		Set @Errmessage = 'If Category is marketSKU then Level Should  be 4'
		Set @ErrStatus = 1
		Goto last
	End	
	Else
	Begin
		Set @tmpCatName = 'Market_SKU'
		Set @CategoryID = ''
		Select @CategoryID = Convert(nVarchar, CategoryID) COLLATE SQL_Latin1_General_CP1_CI_AS from ItemCategories where Category_Name  = @CategoryName 
	End
End
Else If ((Isnull(@CategoryName,'') <> '') and (IsNull(@CategoryLevel,0) = 5))
Begin
--	If (Select Count(*) from Items where Product_Code = @CategoryName) = 0
--	Begin
--		Set @Errmessage = 'Item Not exist in Master'
--		Set @ErrStatus = 1
--		Goto last
--	End	
--	Else
		Set @CategoryID = @CategoryName
End
Else 
	--If Category not exists to revoke
	If ((Select Count(*) From ItemCategories Where Category_Name = @CategoryName) = 0)
	Begin
		If (IsNull(Upper(@type),'') = 'REVOKE') 
		Begin
			Set @Errmessage = 'No Category found in ItemCategories master to Revoke'
			Set @ErrStatus = 1
			Goto last
		End
		Else
		Begin
			Insert Into ItemCategories (Category_Name, Track_Inventory, Price_Option, Level)
				Values(@CategoryName, 1, 1, @CategoryLevel)
			select @tmpCatName = case when @CategoryLevel = 1 then 'Company' when @CategoryLevel = 2 then 'Division' when @CategoryLevel = 3 then 'Sub_Category' when @CategoryLevel = 4 then 'Market_SKU' end
			Select @CategoryID = cast(CategoryID as nvarchar(255)) from ItemCategories where Category_Name  = @CategoryName 
			
		End
	End
--Begin
--		Set @Errmessage = 'No Category found in ItemCategories master'
--		Set @ErrStatus = 1
--		Goto last
--End

--Revoke Functionality

If ((IsNull(@CategoryName,'') <> '') and (IsNull(Upper(@type),'') = 'REVOKE') )
Begin
	Set @Flag = 5
	If ( Select Count(*) from tbl_mERP_MarginDetail Where Code = Convert(nVarchar, @CategoryID) COLLATE SQL_Latin1_General_CP1_CI_AS) >=1
	Begin
		
		Select @MaxID = Max(ID) from tbl_mERP_MarginDetail Where Code = Convert(nVarchar, @CategoryID) COLLATE SQL_Latin1_General_CP1_CI_AS and IsNull(RevokeDate,'') = ''
		Select @OldMargin = isnull(Percentage,0)  from tbl_mERP_MarginDetail Where Id = @MaxID
		Select @OldmarginDate = EffectiveDate from tbl_mERP_MarginDetail Where ID = @MaxID --MarginID = @CategoryID
		If (@OldmarginDate <= @MarginDate)
		Begin
			If (@Percentage > 0 ) --If Given % is greater than 0
			Begin
				If (@OldMargin = @Percentage) -- If Given and available % is matched
					Begin
						Update tbl_mERP_MarginDetail Set RevokeDate = @marginDate Where ID = @MaxID 
					End
				Else
					Begin
						Set @Errmessage = 'Old Margin is Not Matched With Current Margin' 
						Set @ErrStatus = 1
						Goto last
					End
			End
			Else --If % not given
			Begin
					Update tbl_mERP_MarginDetail Set RevokeDate = @marginDate Where ID = @MaxID
			End
		End
		Else
			Begin
				Set @Errmessage = 'Old Margin Date is  greater than Current MarginDate' 
				Set @ErrStatus = 1
				Goto last
			End
	End
End

Truncate Table #tempCategory

If (@Flag <> 5)
Begin
	If ((IsNull(@CategoryName,'') <> '')) 
	Begin
		If @tmpCatName=N'Sub_Category'
			select @ProdHierarchy=HierarchyName from Itemhierarchy where HierarchyID=3
		Else if @tmpCatName=N'Division'
			Begin
			select @ProdHierarchy=HierarchyName from Itemhierarchy where HierarchyID=2
			
			end
		Else if @tmpCatName=N'Market_SKU'
			select @ProdHierarchy=HierarchyName from Itemhierarchy where HierarchyID=4	
		
		If ((IsNull(@tmpCatName,'') = 'Division') Or (IsNull(@tmpCatName,'') = 'Sub_Category') Or (IsNull(@tmpCatName,'') = 'Market_SKU'))
			Begin
			exec dbo.GetLeafCategories @ProdHierarchy, @CategoryName				
			delete from #tempCategory where cast(categoryID as nvarchar(255)) = @CategoryName						
			end
		Else if (isnull(@tmpCatName,'') <> 'Company')
		Begin
--			If (Select Count(*) from items where Product_code = Ltrim(Rtrim(@CategoryName))) >=1	
			
			Begin
				Insert Into #tempCategory
				Select @CategoryName,0
			End
			
		End

		If (Isnull(@CategoryLevel,0) <> 5)
		Begin
		
			Truncate table #TmpGRN
			Insert into #TmpGRN
			select Distinct GRNID from
			Items,
			GRNDetail
			where Items.CategoryID in ( select isnull(CategoryID,0) from #tempCategory)
			and GRNDetail.Product_Code=Items.Product_Code
			and Items.Active=1
		End
		Else
		Begin
			Truncate table #TmpGRN
			Insert into #TmpGRN
			select Distinct GRNID from
			Items, GRNDetail	
			Where GRNDetail.Product_Code=Items.Product_Code
			and GRNDetail.Product_Code= (select isnull(CategoryID,0) from #tempCategory)
			and Items.Active=1
		End

		select @GRNID=isnull(Max(GRNID),0) from GRNAbstract where GRNID in (select GRNID from #TmpGRN)
		and (GRNStatus & 96) =0 


		If IsNull(@GRNID,0)=0
		   Set @MarginDate = @MarginDate
		Else
		   select @GRNDate = GRNDate from  GRNAbstract where GRNID=IsNull(@GRNID,0)
		
--		If (@MarginDate < @GRNDate)
--		Begin
--			Set @Errmessage = 'MarginDate is lesser than GRNDate'
--			Set @ErrStatus = 1
--			Goto last
--		End
--		Else If (@MarginDate = @GRNDate)
--		Begin
--			Set @MarginDate = DateAdd(day, 1, @MarginDate)  
--		End
--		Else
--			Set @MarginDate = @MarginDate


		If (@MarginDate <= @GRNDate)
		Begin
			Set @MarginDate = DateAdd(day, 1, @GRNDate)  
		End
		Else
			Set @MarginDate = @MarginDate
	End
End -- End of Flag Check

Insert Into #TmpChannelMargin(ID,RecdID,RecdDetID,ChannelTypeCode,RegFlag,CategoryName,Categorylevel,MarginPercentage)
Select D.ID,D.RecdID, D.RecdDetID, D.ChannelTypeCode, 
Case When D.RegFlag = 'UnRegistered' Then 1 When D.RegFlag = 'Registered' Then 2 Else 3 End, 
@CategoryID , D.CategoryLevel, D.MarginPercentage 
from tbl_mERP_RecdMarginDetail A,tbl_mERP_RecdChannelMarginDetail D
where A.RecdID = D.RecdID And A.CategoryName = D.CategoryName And A.Categorylevel = D.Categorylevel
And D.RecdID = @ID And RecdDetID = @SlNo  And IsNull(A.Status,0) = 0

If ( Select Count(*) from tbl_mERP_OLClass where Channel_Type_Code Not In (Select Distinct ChannelTypeCode from #TmpChannelMargin)) =1
Begin
	Set @Errmessage = 'Invalid Channel Type Code'
	Set @ErrStatus = 1
	Goto last
End

--Select * from #TmpChannelMargin
--Select * from #tempcategory
Declare @MarDetID Int
If (@Flag <> 5 and isnull(@CategoryID,'') <> '' )
Begin
	If (Isnull(@CategoryLevel,0) <> 5)
	Begin
		Insert Into tbl_mERP_MarginDetail(MarginID, Code, Level, Percentage, EffectiveDate)
		Values (@marginAbsID, @CategoryID, @CategoryLevel,@Percentage , @MarginDate)
		
		Set @MarDetID = 	@@IDENTITY
		
		Insert Into tbl_mERP_ChannelMarginDetail(RecdChannelID,MarginID, MarginDetID, ChannelTypeCode, RegFlag, CatCode, CatLevel ,MarginPerc)
		Select ID,@marginAbsID, @MarDetID  , ChannelTypeCode,RegFlag ,@CategoryID, CategoryLevel, MarginPercentage from #TmpChannelMargin				
	End
	Else
	Begin
		Insert Into tbl_mERP_MarginDetail(MarginID,  Level, Percentage, EffectiveDate, Code)
		Select @marginAbsID, @CategoryLevel,@Percentage , @MarginDate, CategoryID From #tempcategory 
		
		Set @MarDetID = 	@@IDENTITY
		
		Insert Into tbl_mERP_ChannelMarginDetail(RecdChannelID,MarginID, MarginDetID, ChannelTypeCode, RegFlag, CatLevel ,MarginPerc, CatCode)
		Select ID, @marginAbsID, @MarDetID , ChannelTypeCode, RegFlag,CategoryLevel, MarginPercentage,CategoryID 
		from #TmpChannelMargin, #tempcategory
				
	End	
End
-- Status Updation
Truncate Table #TmpChannelMargin
Update tbl_mERP_RecdMarginAbstract  Set Status = 1 where id =@ID
If @CategoryID <> ''
Begin
	Update tbl_mERP_RecdMarginDetail Set Status = 1  Where ID = @SlNo  and RecdID = @ID
	Update tbl_mERP_RecdChannelMarginDetail Set Status = 1  Where ID = @SlNo  and RecdID = @ID
	Set @ProcessItmCnt = @ProcessItmCnt + 1 
End
Else
Begin
	Update tbl_mERP_RecdMarginDetail Set Status = 2  Where ID = @SlNo  and RecdID = @ID
	--Update tbl_mERP_RecdChannelMarginDetail Set Status = 2  Where ID = @SlNo  and RecdID = @ID
	Set @Errmessage = 'Invalid Category Mapping exists in Master' 
	Set @ErrStatus = 1
End

Last:
	-- Error Log Written and Status Updation of rejected Detail 
	If (@ErrStatus = 1)
	Begin
		Set @KeyValue = ''
		Set @KeyValue = Convert(nVarchar, @ID) COLLATE SQL_Latin1_General_CP1_CI_AS + '|' COLLATE SQL_Latin1_General_CP1_CI_AS + Convert(nVarchar,@SlNo) COLLATE SQL_Latin1_General_CP1_CI_AS
		If @ProcessItmCnt = 0
		Begin 
			Update tbl_mERP_RecdMarginAbstract Set Status = 2 where id =@ID
		End
		Update tbl_mERP_RecdMarginDetail Set Status = 2  Where ID = @SlNo  and RecdID = @ID
		Update tbl_mERP_RecdChannelMarginDetail Set Status = 2  Where ID = @SlNo  and RecdID = @ID
		Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)    
		Values('MarginUpdate', @Errmessage,  @KeyValue, getdate())  
	End

Fetch Next From marginCursor Into @CategoryName,  @CategoryLevel,  @Percentage , @MarginDate, @Type, @SlNo 
End

Close MarginCursor
DeAllocate MarginCursor

drop table #tempCategory
drop table #TmpGRN 
Drop Table #TmpChannelMargin
