Create Procedure mERP_sp_Remove_CatProp(@RecdCatID int, @CategoryID Int)
As
Delete From Category_Properties Where CategoryID = @CategoryID
Delete From Item_Properties Where Product_Code = (Select Product_Code From Items Where CategoryID = @CategoryID)
