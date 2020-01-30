  
CREATE Function Fn_Get_AllItems_ITC(@GroupID nVarchar(1000))
Returns @Items Table  
(  
 Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS  
)  
As  
Begin  
	Declare @OCGFlag as Int
	Set @OCGFlag = (select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS')
If isnull(@OCGFlag ,0) = 0
 Begin
	Insert Into @Items 
	Select Product_Code, ProductName  
	From v_mERP_ItemWithCG
	Where GroupID In(Select * From dbo.sp_splitIn2Rows(@GroupID,','))
	Group by Product_Code, ProductName

 End
Else
 Begin
	Insert Into @Items 
	Select Product_Code, ProductName  
	From Fn_GetOCGSKU(@GroupID)
 End
	Return  
End
