Create Procedure mERP_SP_InsertSchemeMinQty
(  
@SchemeID int,  
@Category nVarchar(256),  
@CATEGORY_LEVEL int,  
@MIN_RANGE decimal(18,6),  
@UOM int  
)  
As  
BEGIN
	Insert Into RecdSchMinQty(CS_SchemeID,Category,CATEGORY_LEVEL,MIN_RANGE,UOM)  
	values(@SchemeID, @Category, @CATEGORY_LEVEL, @MIN_RANGE, @UOM)  
END
