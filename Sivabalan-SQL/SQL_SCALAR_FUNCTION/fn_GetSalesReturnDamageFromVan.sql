
CREATE FUNCTION fn_GetSalesReturnDamageFromVan(@RefForDocSerial Int=0)
RETURNS Varchar(8000)
AS
BEGIN
    DECLARE @ITEM_CODE nVarchar(250)
    DECLARE @DMG_QTY nvarchar(10)
    DECLARE @ITEM_TYPE nVarchar(5)
    DECLARE @RESULT nVarchar(4000)	
    DECLARE VanReturn_Damages Cursor FOR 
    SELECT InvDt.Product_code, Cast(Sum(InvDt.Quantity) as Varchar(10)) DamageQty, Case When IsNull(InvDt.FlagWord,0) = 1 Then 'FREE' Else ' ' END as FREEITEM
    FROM Batch_Products BP, InvoiceDetail InvDt, InvoiceAbstract InvAb
    WHERE
	InvAb.InvoiceId = InvDt.InvoiceID
	And BP.Product_Code = InvDt.Product_Code 
	And IsNull(BP.Batch_Number,'') = IsNull(InvDt.Batch_Number,'') 
	And BP.Batch_Code = InvDt.Batch_Code 
	And BP.Damage=2 And InvAb.InvoiceType = 4 
	And InvAb.ReferenceNumber = CONVERT(nVarchar(10),@RefForDocSerial)
    GROUP BY InvDt.Product_code, InvDt.FlagWord
    OPEN VanReturn_Damages
    set	@RESULT = N''
       FETCH NEXT FROM VanReturn_Damages INTO @ITEM_CODE, @DMG_QTY, @ITEM_TYPE
	WHILE @@FETCH_STATUS = 0      		
	BEGIN
	   IF Len(@RESULT) = 0 
	   Set @RESULT =  (@ITEM_CODE + SPACE(30 - LEN(@ITEM_CODE)))+ N';' + @DMG_QTY + N';' + @ITEM_TYPE
           ELSE
	   Set @RESULT =  @RESULT + N':' + (@ITEM_CODE + SPACE(30 - LEN(@ITEM_CODE))) + N';' + @DMG_QTY + N';' + @ITEM_TYPE
	   FETCH NEXT FROM VanReturn_Damages INTO @ITEM_CODE, @DMG_QTY, @ITEM_TYPE
	END
    CLOSE VanReturn_Damages
    DEALLOCATE VanReturn_Damages
    RETURN(@RESULT) 	    
END

