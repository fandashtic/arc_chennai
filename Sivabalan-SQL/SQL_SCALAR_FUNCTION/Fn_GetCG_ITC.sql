CREATE Function Fn_GetCG_ITC(@InvID As int )
Returns nVarchar(2550)
As
Begin

Declare @GroupID As Int
Declare @TmpItem Table(GroupId Int, Product_Code nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS) 

Declare CursorGroup Cursor For Select Distinct GroupID From ProductCategoryGroupAbstract
Open CursorGroup
Fetch From CursorGroup Into @GroupID
While @@Fetch_Status = 0    
  Begin    
   Insert Into @TmpItem Select @GroupID,Product_Code From dbo.Sp_Get_ItemsFrmCG_ITC(@GroupID)
   Fetch Next From CursorGroup Into @GroupID
  End
Close CursorGroup
DeAllocate CursorGroup

Declare @GroupName As nVarchar(256)
Declare @ConGroupName as nVarchar(2550)

Declare CGN Cursor For 
Select Distinct pcga.GroupName From Productcategorygroupabstract pcga, @TmpItem tit
Where pcga.GroupID = tit.GroupID And tit.Product_Code In ( Select Product_Code From InvoiceDetail
Where InvoiceID = @InvID)
Open CGN
Fetch From CGN Into @GroupName
While @@Fetch_Status = 0    
  Begin    
	Set @ConGroupName = IsNull(@ConGroupName, '') + ' ' + @GroupName + ' |'
    Fetch Next From CGN Into @GroupName
  End
Close CGN
DeAllocate CGN

Set @ConGroupName = Left(@ConGroupName, Len(@ConGroupName) - 1)
Return @ConGroupName

End

