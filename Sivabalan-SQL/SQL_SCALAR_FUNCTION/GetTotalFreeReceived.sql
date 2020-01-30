Create FUNCTION GetTotalFreeReceived(@ITEMCODE nvarchar(15), @FROMDATE datetime, @TODATE datetime)  
RETURNS decimal(18,6)  
AS  
BEGIN  
	RETURN IsNull((Select Sum(FreeQty) From GRNAbstract, GRNDetail   
	Where GRNDetail.GRNID = GRNAbstract.GRNID And  
	GRNAbstract.GRNDate Between @FROMDATE And @TODATE And  
	((GRNAbstract.GRNStatus & 64)=0 And (GRNAbstract.GRNStatus & 32)= 0 )
	And Product_Code = @ITEMCODE), 0)  
END  
