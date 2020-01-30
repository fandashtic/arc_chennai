CREATE PROCEDURE sp_Get_ChannelPTR_SO(
		@CustomerID nvarchar(15),
		@PRODUCT_CODE nvarchar(15),
		@BatchNumber nvarchar(255)   
        )      
AS      

Declare @ChannelTypeCode nvarchar(15)
Declare @RegisterStatus int

Select @RegisterStatus = Case When isnull(IsRegistered,0) = 0 Then 1 Else 2 End From Customer Where CustomerID = @CustomerID

Select Top 1 @ChannelTypeCode = Channel_Type_Code From tbl_mERP_OLClassMapping OLMap 
Inner Join tbl_mERP_OLClass OLClass ON OLMap.OLClassID = OLClass.ID 
Where OLMap.CustomerID = @CustomerID and isnull(OLMap.Active,0) = 1

Select Top 1 Case When isnull(C.ChannelPTR, 0) = 0 Then BP.PTR Else C.ChannelPTR End 'ChannelPTR', BP.PTR
From Batch_Products BP 
Left Join BatchWiseChannelPTR C ON BP.Batch_Code = C.Batch_Code and C.ChannelTypeCode = @ChannelTypeCode and isnull(C.RegisterStatus,0) & @RegisterStatus <> 0
Where BP.Product_Code= @PRODUCT_CODE 
	and (isnull(Batch_Number,'') = @BatchNumber or isnull(Batch_Number,'') = '')
	and BP.Quantity > 0 And ISNULL(BP.Damage, 0) = 0
Group By C.ChannelPTR, BP.PTR
Order By Min(BP.Batch_Code)

