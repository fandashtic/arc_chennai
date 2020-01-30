Create Procedure sp_CheckItemExists_ITC(@GroupID nVarchar(1000), @ItemCode nvarchar(15), @InvID Int = 0, @Mode Int =0 )
As
	If @GroupID = '' Or @GroupID = '0' Or isNull(@GroupID,'-1') = '-1'
		Select 1
	Else	
		If @Mode = 2 --Invoice amendment
			Select Count(Product_Code) From dbo.Fn_Get_Items_ITC_InvAmend(@GroupID,@InvID)
			Where Product_Code = @ItemCode
		Else
			Select Count(Product_Code) From dbo.Fn_Get_AllItems_ITC(@GroupID)
			Where Product_Code = @ItemCode
