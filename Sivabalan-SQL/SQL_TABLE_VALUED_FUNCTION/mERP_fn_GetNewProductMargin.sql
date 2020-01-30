CREATE Function mERP_fn_GetNewProductMargin
(
@InvNumber int,
@GRNDate DateTime = Null
)
RETURNS @ARRAY TABLE (Product_Code nvarchar(150)COLLATE SQL_Latin1_General_CP1_CI_AS,
OldMargin decimal(18,6),Percentage decimal(18,6))    
AS
Begin    
Declare @PTRMargin Decimal(18,6)
Declare @ItemCode nvarchar(150)
Declare @CatID Int
Declare @ParentID int
declare @Revokedate datetime
Declare @MarginID int
Declare @RDate datetime
Declare @TDate datetime

Declare @TmpMargin Table (id int,Percentage decimal(18,6),Edate datetime,RevokeDate datetime)

If @GRNDate Is Null 
Set @GRNDate = GetDate()

Declare Cur_PurInv Cursor for 
Select Distinct Product_Code from InvoiceDetailReceived where INvoiceID=@InvNumber 
Open Cur_PurInv
Fetch Next from Cur_PurInv into @ItemCode
While @@FETCH_STATUS=0
Begin
	if Exists(select * from tbl_mERP_MarginDetail where Code=@ItemCode and Level=5 and dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
    --and (case when Revokedate is null then 1 when dbo.striptimefromdate(RevokeDate)  >= dbo.striptimefromdate(@GRNDate) then 1 else 0 end)=1)
	Begin 
         Insert into  @TmpMargin
		 Select ID,Percentage,EffectiveDate,RevokeDate from tbl_mERP_MarginDetail where ID in 
		 (select (ID) from tbl_mERP_MarginDetail
		 where Code=@ItemCode And Level=5 and dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
         /*and (case when Revokedate is null then 1 
         when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) 
         then 1 
         else 
         0 end)=1  */
	End	
    Set @ParentID=1
    Select @CatID=CategoryID from Items where Product_Code = @ItemCode
    While @ParentID<>0
    Begin
		If Exists(Select * from tbl_mERP_MarginDetail where Code=Cast(@CatID as nvarchar) 
		   And Level<>5 And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
           --and (case when Revokedate is null then 1 when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 else 0 end)=1)        
		Begin			
            Insert into  @TmpMargin
			Select ID,Percentage,Effectivedate,RevokeDate from tbl_mERP_MarginDetail where ID in 				 
			(select (ID) from tbl_mERP_MarginDetail
			Where Code=Cast(@CatID as nvarchar) And Level<>5 And dbo.striptimefromdate(EffectiveDate) <= dbo.striptimefromdate(@GRNDate))
			/*and (case when Revokedate is null then 1 
			when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) 
			  then 1 
			else 
			  0 end)=1 */        
			Select @CatID=ParentID from ItemCategories where CategoryID=@CatID
			Set @ParentID=@CatID  
		End
		Else
		Begin			
			Select @CatID=ParentID from ItemCategories where CategoryID=@CatID
			Set @ParentID=@CatID  
		End   
	End    

	--Select @PTRMargin = IsNull(Percentage,0) from @TmpMargin where Edate=(select Max(Edate) from @TmpMargin)

    Select @Revokedate = RevokeDate from @TmpMargin where ID=(select isnull(Max(ID),0) from @TmpMargin)
   
    If  @Revokedate is null
    Begin 
        Select @PTRMargin = IsNull(Percentage,0) from @TmpMargin where ID=(select isnull(Max(ID),0) from @TmpMargin)
        And dbo.striptimefromdate(Edate)=dbo.striptimefromdate(@GRNDate)
    End
    Else
    Begin
        Select @MarginID=isnull(Max(ID),0) from @TmpMargin where
   	    (case when Revokedate is null then 1 
	    when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 
	    Else  0 end)=1

        Select @RDate = IsNull(RevokeDate,0) from @TmpMargin where ID=
        (select Max(X.ID) from (select isnull(ID,0) as 'ID' from @TmpMargin where
        (case when Revokedate is null then 1 
		 --when dbo.striptimefromdate(RevokeDate) >= dbo.striptimefromdate(@GRNDate) then 1 
         when (dbo.striptimefromdate(@GRNDate)-dbo.striptimefromdate(RevokeDate))=1 then 1 
	     Else  0 end)=1) X)		
		
		
        Set @RDate=dbo.striptimefromdate(@RDate)
        Set @TDate=dbo.striptimefromdate(@GRNDate)-1
                
        If (@RDate-@TDate)=0
        Begin           
           Select @PTRMargin=IsNull(Percentage,0) from @TmpMargin where ID=@MarginID
        End
        Else
        Begin
           Select @PTRMargin=IsNull(Percentage,0) from @TmpMargin where ID=@MarginID
           And dbo.striptimefromdate(Edate)=dbo.striptimefromdate(@GRNDate)           
        End
    End
    Insert into @ARRAY Select @ItemCode,isNull(dbo.merp_fn_Get_ProductMargin(@ItemCode,@GRNDate-1),0),isnull(@PTRMargin,0) 
    
    delete from @TmpMargin
    set @PTRMargin=0
    Set @RDate=NUll
    Set @TDate=Null
    Set @Revokedate=NUll
	Fetch Next from Cur_PurInv into @ItemCode 
End
Close Cur_PurInv
Deallocate Cur_PurInv

Return 
End
