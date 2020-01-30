Create PROCEDURE sp_update_ImportItem_MUOM(
@Product_Code nvarchar(15),    
@Uom1 int,  
@Uom2 int,  
@Uom1Conversion Decimal(18,6),  
@Uom2Conversion Decimal(18,6),  
@DefaultUom int,
@PriceAtUOMLevel int=0,
@Version nVarChar(15) = N'')  
AS      

Declare @ScreenCode nVarchar(100)



If @Version = 'CUG'
Begin

	Select @ScreenCode = ScreenCode from tbl_mERP_ConfigAbstract 
	Where ScreenName = 'Import Item Modify'

	--UOM1 And UOM1Conversion will be updated only when both the columns are
	--not locked.
	If (IsNull((Select Flag from tbl_mERP_ConfigDetail 
	Where ScreenCode = @ScreenCode And ControlName = 'UOM1'),1) <> 0 And
	IsNull((Select Flag from tbl_mERP_ConfigDetail 
	Where ScreenCode = @ScreenCode And ControlName = 'UOM1Conversion'),1) <> 0)
	UPDATE Items SET UOM1 = @Uom1,UOM1_Conversion = @Uom1Conversion WHERE Product_Code = @Product_Code

	--UOM2 And UOM2Conversion will be updated only when both the columns are
	--not locked.
	If (IsNull((Select Flag from tbl_mERP_ConfigDetail 
	Where ScreenCode = @ScreenCode And ControlName = 'UOM2'),1) <> 0 And
	IsNull((Select Flag from tbl_mERP_ConfigDetail 
	Where ScreenCode = @ScreenCode And ControlName = 'UOM2Conversion'),1) <> 0)
	UPDATE Items SET UOM2 = @Uom2,UOM2_Conversion = @Uom2Conversion WHERE Product_Code = @Product_Code



	If IsNull((Select Flag from tbl_mERP_ConfigDetail 
	Where ScreenCode = @ScreenCode And ControlName = 'SalesDefaultUom'),1) <> 0
	UPDATE Items SET DefaultUOM = @DefaultUom WHERE Product_Code = @Product_Code

	If IsNull((Select Flag from tbl_mERP_ConfigDetail 
	Where ScreenCode = @ScreenCode And ControlName = 'PriceAtUOMLevel'),1) <> 0
	UPDATE Items SET PriceAtUOMLevel = @PriceAtUOMLevel WHERE Product_Code = @Product_Code


End
Else
Begin
	   UPDATE Items SET UOM1 = @Uom1,  
	   UOM2 = @Uom2,  
	   UOM1_Conversion = @Uom1Conversion,  
	   UOM2_Conversion = @Uom2Conversion,  
	   DefaultUOM = @DefaultUom,
	   PriceAtUOMLevel = @PriceAtUOMLevel   
	   WHERE Product_Code = @Product_Code
End


