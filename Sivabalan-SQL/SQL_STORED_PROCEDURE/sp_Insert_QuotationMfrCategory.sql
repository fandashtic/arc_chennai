CREATE  PROCEDURE sp_Insert_QuotationMfrCategory(@QuotationID INT,    
          @MfrCategoryID INT,    
          @MarginOn INT,    
          @MarginPercentage Decimal(18,6),    
          @Tax Decimal (18,6),    
          @Discount Decimal(18,6),    
          @AllowScheme INT,    
          @QuotationType INT,
		  @QuotedLSTTax Int = 0,	
	      @QuotedCSTTax Int = 0)    
AS  
Declare @Category_Name  as nvarchar(100)  
Begin    
if @Tax = 0
BEGIN
 INSERT INTO [QuotationMfrCategory](QuotationID,    
       MfrCategoryID,    
       MarginOn,    
       MarginPercentage,    
       Tax,    
       Discount,    
       AllowScheme,    
       QuotationType,
	   Quoted_LSTTax,
	   Quoted_CSTTax)     
   VALUES(    @QuotationID,    
       @MfrCategoryID,    
       @MarginOn,    
       @MarginPercentage,    
	   -1,
       @Discount,    
       @AllowScheme,    
       @QuotationType,
	   @QuotedLSTTax,
	   @QuotedCSTTax)  
END
ELSE
BEGIN
INSERT INTO [QuotationMfrCategory](QuotationID,    
       MfrCategoryID,    
       MarginOn,    
       MarginPercentage,    
       Tax,    
       Discount,    
       AllowScheme,    
       QuotationType,
	   Quoted_LSTTax,
	   Quoted_CSTTax)    
   VALUES(@QuotationID,    
       @MfrCategoryID,    
       @MarginOn,    
       @MarginPercentage,    
       @Tax,    
       @Discount,    
       @AllowScheme,    
       @QuotationType,
	   @QuotedLSTTax,
	   @QuotedCSTTax)	  
END
   Create table #tempCategory(CategoryID int,Status int)  
   select @Category_Name=Category_Name from ItemCategories where CategoryID=@MfrCategoryID  
   Exec dbo.GetLeafCategories '%',@Category_name  
	If @tax = 0
	BEGIN
		Insert into  QuotationMfrCategory_LeafLevel   
		select @QuotationID,CategoryID,@MarginOn,@MarginPercentage,-1,@Discount,@AllowScheme,@QuotationType,@QuotedLSTTax,@QuotedCSTTax from #tempCategory  
	END
	ELSE
	BEGIN
		Insert into  QuotationMfrCategory_LeafLevel   
		select @QuotationID,CategoryID,@MarginOn,@MarginPercentage,@tax,@Discount,@AllowScheme,@QuotationType,@QuotedLSTTax,@QuotedCSTTax from #tempCategory  
	END
   truncate table #tempCategory  
   drop table #tempCategory    
End  
