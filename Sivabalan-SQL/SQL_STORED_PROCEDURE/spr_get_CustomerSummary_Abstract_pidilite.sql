CREATE procedure spr_get_CustomerSummary_Abstract_pidilite (@Customer nvarchar(2550),     
@CATEGORY nvarchar(2550), @FromDate DateTime, @ToDate DateTime)        
AS        
BEGIN        
	DECLARE @Delimeter as Char(1)        
	SET @Delimeter=Char(15)      
	Create table #tmpCustomer(Customer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
	if @Customer= N'%'         
		Insert into #tmpCustomer select Company_Name from Customer        
	Else        
		Insert into #tmpCustomer select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)        
	    
	Create table #tempCategory(CategoryID Int, Status Int)                  
	Exec GetLeafCategories N'%', @CATEGORY    
	
	Select CustomerID , Customer , "TotalQty" =  Sum(TotalQty),"Total Sale Value" = Sum(TotalSaleValue)
	From 
	(Select Cus.CustomerID, "Customer" = Cus.Company_Name,"TotalQty"= Sum(Invd.Quantity),
	"TotalSaleValue" = sum(Distinct 
	case IA.InvoiceType     
	when 4 then -IA.NetValue     
	when 5 then -IA.NetValue    
	when 6 then -IA.NetValue     
	else IA.NetValue end)        
	From  Customer Cus, InvoiceAbstract IA,InvoiceDetail Invd, Items
	Where Cus.CustomerID = IA.CustomerID
	and IA.InvoiceId=Invd.InvoiceId    
	and Invd.Product_Code = Items.Product_Code    
	and Items.CategoryID In (Select CategoryID From #tempCategory)    
	and Cus.Company_Name IN (Select Customer COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpCustomer)         
	and IA.InvoiceDate between @FromDate and @ToDate        
	--and IA.InvoiceType <> 2        
	and (IA.Status & 192) = 0        
	Group by Cus.CustomerID, Cus.Company_Name, IA.InvoiceID ) As Tot
	Group By CustomerID,Customer
	
	Drop Table #tmpCustomer    
	Drop Table #tempCategory   
END        
