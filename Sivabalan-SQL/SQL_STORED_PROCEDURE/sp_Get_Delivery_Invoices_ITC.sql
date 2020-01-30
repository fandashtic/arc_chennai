CREATE PROCEDURE sp_Get_Delivery_Invoices_ITC
(         
 @FromDate	DateTime,
 @ToDate	DateTime,
 @Beat NVarChar(4000) = N'',
 @SalesMan NVarChar(4000) = N'',
 @DeliveryStatus Int = 0,
 @Van NVarChar(4000) = N''
)
AS  

Create Table #TblSalesman(SalesManID Int)
Create Table #TblBeat(BeatID Int)

If @SalesMan = N''
 Begin
  Insert InTo #TblSalesman Values(0)
  Insert InTo #TblSalesman Select SalesmanID From SalesMan Where Active = 1
 End
Else
 Insert InTo #TblSalesman Select * From sp_SplitIn2Rows(@SalesMan,N',') 

If @Beat = N''	
 Begin
  Insert InTo #TblBeat Values(0)
	 Insert InTo #TblBeat Select BeatID From Beat Where Active = 1
 End
Else
	 Insert InTo #TblBeat Select * From sp_SplitIn2Rows(@Beat,N',')

If @DeliveryStatus = 0 
  Select
  	"CustomerID" = InvoiceAbstract.CustomerID,Company_Name,InvoiceID,InvoiceDate,         
  	NetValue,InvoiceType,InvoiceAbstract.DocumentID,IsNull(InvoiceAbstract.Status, 0),
   IsNull(VanNumber,N''),
  	"Weight" = 
    IsNull(
     (Select 
   				Sum(IsNull(IDE.Quantity,0) * IsNull(COnversiOnFactOr,0))
   			From 
   				InvoiceDetail IDE, Items   
   			Where 
   					IDE.InvoiceID = InvoiceAbstract.InvoiceID 
    				And IDE.Product_Code = Items.Product_Code)
     ,0),
  	"Beat" = Beat.[Description],Customer.SequenceNo     
  From 
  	InvoiceAbstract
	inner join Customer on 	InvoiceAbstract.CustomerID = Customer.CustomerID
	left outer join Beat  on IsNull(InvoiceAbstract.BeatID,0) = Beat.BeatID
  Where 
  	(InvoiceType = 1 Or InvoiceType = 3)           
  	And	IsNull(InvoiceAbstract.BeatID,0) In (Select BeatID From #TblBeat)
  	And	IsNull(InvoiceAbstract.SalesmanID,0) In (Select SalesManID From #TblSalesman)
  	And	InvoiceDate Between @FromDate And @ToDate     
  	And	(IsNull(Status,0) & 128) = 0
   And IsNull(DeliveryStatus,0) = @DeliveryStatus
Else
 Begin
  Select
  	"CustomerID" = InvoiceAbstract.CustomerID,Company_Name,InvoiceID,InvoiceDate,         
  	NetValue,InvoiceType,InvoiceAbstract.DocumentID,IsNull(InvoiceAbstract.Status, 0),
   IsNull(VanNumber,N''),
  	"Weight" = 
    IsNull(
     (Select 
   				Sum(IsNull(IDE.Quantity,0) * IsNull(COnversiOnFactOr,0))
   			From 
   				InvoiceDetail IDE, Items   
   			Where 
   					IDE.InvoiceID = InvoiceAbstract.InvoiceID 
    				And IDE.Product_Code = Items.Product_Code)
     ,0),
  	"Beat" = Beat.[Description],Customer.SequenceNo     
   From 
  	InvoiceAbstract
	inner join Customer on 	InvoiceAbstract.CustomerID = Customer.CustomerID
	left outer join Beat  on IsNull(InvoiceAbstract.BeatID,0) = Beat.BeatID
  Where 
  	(InvoiceType = 1 Or InvoiceType = 3)           
  	And	IsNull(InvoiceAbstract.BeatID,0) In (Select BeatID From #TblBeat)
  	And	IsNull(InvoiceAbstract.SalesmanID,0) In (Select SalesManID From #TblSalesman)       
  	And	InvoiceDate Between @FromDate And @ToDate     
  	And	(IsNull(Status,0) & 128) = 0
   And IsNull(VanNumber, N'') Like 
    Case IsNull(@Van,'')
     When N'' Then N'%'
     Else @Van
    End
   And IsNull(DeliveryStatus,0) = @DeliveryStatus
   And IsNull(PaymentMode,0) = 1
  Union All
  Select 
  	"CustomerID" = InvoiceAbstract.CustomerID,Company_Name,InvoiceID,InvoiceDate,         
  	NetValue,InvoiceType,InvoiceAbstract.DocumentID,IsNull(InvoiceAbstract.Status, 0),
   IsNull(VanNumber,N''),
  	"Weight" = 
    IsNull(
     (Select 
   				Sum(IsNull(IDE.Quantity,0) * IsNull(COnversiOnFactOr,0))
   			From 
   				InvoiceDetail IDE, Items   
   			Where 
   					IDE.InvoiceID = InvoiceAbstract.InvoiceID 
    				And IDE.Product_Code = Items.Product_Code)
     ,0),
  	"Beat" = Beat.[Description],Customer.SequenceNo     
  From 
  	InvoiceAbstract
	inner join Customer on 	InvoiceAbstract.CustomerID = Customer.CustomerID
	left outer join Beat  on IsNull(InvoiceAbstract.BeatID,0) = Beat.BeatID     
  Where 
  	(InvoiceType = 1 Or InvoiceType = 3)      
  	And	IsNull(InvoiceAbstract.BeatID,0) In (Select BeatID From #TblBeat)
  	And	IsNull(InvoiceAbstract.SalesmanID,0) In (Select SalesManID From #TblSalesman)    
  	And	InvoiceDate Between @FromDate And @ToDate     
  	And	(IsNull(Status,0) & 128) = 0
   And IsNull(VanNumber, N'') Like 
    Case IsNull(@Van,'')
     When N'' Then N'%'
     Else @Van
    End
   And IsNull(DeliveryStatus,0) = @DeliveryStatus
   And IsNull(PaymentMode,0) = 0
   And dbo.sp_Invoice_Implicit_Explicit_Collections(InvoiceAbstract.InvoiceID) = 0
  Union All
  Select 
  	"CustomerID" = InvoiceAbstract.CustomerID,Company_Name,InvoiceID,InvoiceDate,         
  	NetValue,InvoiceType,InvoiceAbstract.DocumentID,IsNull(InvoiceAbstract.Status, 0),
   IsNull(VanNumber,N''),
  	"Weight" = 
    IsNull(
     (Select 
   				Sum(IsNull(IDE.Quantity,0) * IsNull(COnversiOnFactOr,0))
   			From 
   				InvoiceDetail IDE, Items   
   			Where 
   					IDE.InvoiceID = InvoiceAbstract.InvoiceID 
    				And IDE.Product_Code = Items.Product_Code)
     ,0),
  	"Beat" = Beat.[Description],Customer.SequenceNo     
 
   From 
  	InvoiceAbstract
	inner join Customer on 	InvoiceAbstract.CustomerID = Customer.CustomerID
	left outer join Beat  on IsNull(InvoiceAbstract.BeatID,0) = Beat.BeatID
  	inner join Collections on  InvoiceAbstract.PaymentDetails = Collections.DocumentID
  Where 
  	(InvoiceType = 1 Or InvoiceType = 3)           
  	And	IsNull(InvoiceAbstract.BeatID,0) In (Select BeatID From #TblBeat)
  	And	IsNull(InvoiceAbstract.SalesmanID,0) In (Select SalesManID From #TblSalesman)  
  	And	InvoiceDate Between @FromDate And @ToDate     
  	And	(IsNull(InvoiceAbstract.Status,0) & 128) = 0
   And IsNull(VanNumber, N'') Like 
    Case IsNull(@Van,'')
     When N'' Then N'%'
     Else @Van
    End
   And IsNull(InvoiceAbstract.DeliveryStatus,0) = @DeliveryStatus
   And InvoiceAbstract.PaymentMode In (3,2)
   And (IsNull(Collections.Status,0) = 2 or IsNull(Collections.Status,0) = 0)
   And dbo.sp_Invoice_Implicit_Explicit_Collections(InvoiceAbstract.InvoiceID) = 0
 End

Drop Table #TblSalesman
Drop Table #TblBeat


