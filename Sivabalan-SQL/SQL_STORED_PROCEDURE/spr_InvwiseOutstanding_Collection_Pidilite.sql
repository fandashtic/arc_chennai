
	Create Procedure spr_InvwiseOutstanding_Collection_Pidilite
	(  
 		@ToDate DateTime,  
 		@Channel nVarchar(2510),
		@Customer nVarchar(2550)
	) 
	As

	Declare @Delimeter as Char(1)
	Declare @Inv as nVarchar(50)

	Set @Delimeter=Char(15)
	Select @Inv = Prefix from VoucherPrefix Where TranID = N'Invoice'

	Create table #TmpCustomer(Customer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	Create table #TmpChannel(ChannelType Int)  
  
	If @Customer = N'%'     
 		Insert into #TmpCustomer select Company_Name from Customer    
	Else    
 		Insert into #TmpCustomer select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)   

	If @Channel = N'%'             
	Begin
 		Insert into #TmpChannel select ChannelType from Customer_channel  
 		Insert into #TmpChannel (ChannelType) Values (0)        
	End
	Else        
	Begin
 		Insert into #TmpChannel Select ChannelType from Customer_Channel
		where ChannelDesc in (select * from dbo.sp_SplitIn2Rows(@Channel,@Delimeter))  
	End


	Select 
		Ia.InvoiceID, "Document ID" = @Inv + Cast(DocumentID as nVarchar),
		"Document Reference" = Ia.DocReference, "Invoice Date"=InvoiceDate, 
    "Payment Date"=PaymentDate, "Customer Name" = Customer.Company_Name,
    "Invoice Gross Value" =
		Case 
			When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - (Ia.GrossValue - Ia.TotalTaxApplicable))
			When (InvoiceType >= 1 And InvoiceType < = 3) Then (Ia.GrossValue - Ia.TotalTaxApplicable)
		End,
    "Product Discount" = Ia.DiscountValue,
    "Scheme Discount" = Ia.SchemeDiscountAmount,
		"Addl Discount" = Ia.AddlDiscountValue,
		"Trade Discount" = Ia.GoodsValue * (IA.DiscountPercentage /100),
		"Tax Amount" = Ia.TotalTaxApplicable,
		"Adj. Doc Ref." = Isnull(Ia.AdjRef,N''),
		"Adj. Amount" = Isnull(Ia.AdjustedAmount,0),
		"Round Off Amount" = Ia.RoundOffAmount,
		"Rounded Net Amount" = 
		Case 
			When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - (Ia.NetValue + Ia.RoundOffAmount))
			When (InvoiceType >= 1 And InvoiceType < = 3) Then (Ia.NetValue + Ia.RoundOffAmount) 
		End,
		"Amount Collected" = (Isnull(NetValue,0) - Isnull(Ia.AdjustedAmount,0) - Isnull(Ia.Balance,0) + Isnull(Ia.RoundOffAmount,0)),
		"Balance" = 
		Case 
			When (InvoiceType >= 4 And InvoiceType < = 6) Then (0 - Isnull(Ia.Balance,0)) 
			When (InvoiceType >= 1 And InvoiceType < = 3) Then Isnull(Ia.Balance,0) 
		End,
		"Due Days" = Datediff(dd,Ia.InvoiceDate,@ToDate),
		"Over Due Days"  = 
		Case 
			When (@ToDate > Ia.PaymentDate) Then Datediff(dd,PaymentDate,@ToDate) 
			Else 0 
		End
	from 
		InvoiceAbstract Ia, Customer 
	Where Ia.CustomerID = Customer.CustomerID  
				And Customer.Company_Name in (Select Customer from #TmpCustomer)
				And Customer.ChannelType in (Select ChannelType from #TmpChannel)
				And Ia.InvoiceType in (1,2,3,4,5,6)
				And (Ia.Status & 128) = 0
				And Ia.Balance > 0
				And Ia.InvoiceDate <= @ToDate
	Order By
	Ia.InvoiceDate
