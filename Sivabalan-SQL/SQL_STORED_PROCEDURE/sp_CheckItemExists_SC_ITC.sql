Create Procedure sp_CheckItemExists_SC_ITC(@GroupID nVarchar(1000), @ItemCode nvarchar(15))
As
	If isNull(@GroupID,'-1') = '-1' Or  isNull(@GroupID,'-1') = '0' or isNull(@GroupID,'') = ''
		Select 1
	Else	
		Select Count(Product_Code) From dbo.Fn_Get_Items_SC_ITC(@GroupID)
		Where Product_Code = @ItemCode

