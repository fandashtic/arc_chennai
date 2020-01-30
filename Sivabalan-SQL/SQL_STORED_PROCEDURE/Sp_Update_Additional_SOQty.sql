CREATE Proc Sp_Update_Additional_SOQty (@InvID int)      
As     
DECLARE @PCODE nVarchar(30), @TOT_QTY Decimal(18,6)       
DECLARE @SOLIST nVarchar(2000)    
Declare @EXS_QTY Decimal(18,6)
Select  @SOLIST = IsNull(SONumber,N'') FRom InvoiceAbstract Where InvoiceID = @InvID   

DECLARE CUR_INVDET Cursor For       
Select Product_code, Sum(Quantity) InvQty From InvoiceDetail       
where invoiceID = @InvID And FlagWord = 0      
Group by Product_code      
Open CUR_INVDET      
FETCH NEXT FROM CUR_INVDET INTO @PCODE, @TOT_QTY      
WHILE @@FETCH_STATUS =0       
  BEGIN      
    DECLARE @SONUMBER nVarchar(30), @SOPENDING Decimal(18,6)  
    DECLARE CUR_SODET CURSOR FOR      
    Select SoNumber, Sum(Pending) SO_Pending      
    From SODetail Where SoNumber in (Select * from dbo.sp_SplitIn2Rows(@SOLIST,N','))      
    And Product_Code = @PCODE
    Group By SoNumber      
    Order By SoNumber  
    OPEN CUR_SODET      
    FETCH NEXT FROM CUR_SODET INTO @SONUMBER, @SOPENDING      
    WHILE @@FETCH_STATUS =0           
    BEGIN        
      IF @TOT_QTY >= @SOPENDING       
        BEGIN      
		  SET @TOT_QTY = @TOT_QTY - @SOPENDING
		  SET @EXS_QTY = @TOT_QTY
        END
      ELSE 
		BEGIN
		  SET @EXS_QTY = 0
		END
      FETCH NEXT FROM CUR_SODET INTO @SONUMBER, @SOPENDING      
    END
    CLOSE CUR_SODET      
    DEALLOCATE CUR_SODET      
	IF @EXS_QTY > 0
	  BEGIN 
		Insert into InvFromSODetail Values(@InvID, @SONUMBER, @PCODE, @EXS_QTY)
	  END	
    FETCH NEXT FROM CUR_INVDET INTO @PCODE, @TOT_QTY      
  END      
CLOSE CUR_INVDET
DEALLOCATE CUR_INVDET





