CREATE Function fn_FromInvNo_ITC(@CustomerID nVarchar(2550),@FromDate DateTime,@ToDate DateTime,@InvType nvarchar(50),@PaymentMode nvarchar(50),@DocType as nVarchar(50))  
Returns @Invoice Table(InvoiceID Int)  
As  
Begin  

Set @FromDate = dbo.StripDateFromTime(@FromDate)
Set @ToDate = dbo.StripDateFromTime(@ToDate)

Declare @tmpCus Table(CustID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )    
Declare @tmpPaymode Table(PayMode Int)            
Declare @TmpPayMode2 Table(PayMode NVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, PId int)  
Declare @TmpInvType Table(InvType int)
Declare @Delimeter as Char(1) 
Set @Delimeter = char(44) 

If @CustomerID = N'%%'  or @CustomerID = N'%'   
	Insert into @tmpCus select CustomerID from Customer Union select cast(Isnull(CustomerID,0) as nvarchar) from Cash_Customer Union Select Cast(-1 As nVarChar)  
Else    
	Insert into @tmpCus select * from dbo.sp_SplitIn2Rows(@CustomerID, @Delimeter) Union Select Cast(-1 As nVarChar)  

Insert Into @TmpPayMode2 Values (N'Credit', 0)  
Insert Into @TmpPayMode2 Values (N'Cash', 1)  
Insert Into @TmpPayMode2 Values (N'Cheque', 2)  
Insert Into @TmpPayMode2 Values (N'DD', 3)  

if @DocType = N'All Document Type' or @DocType ='%'  
	Set @DocType ='%'     

if @PaymentMode = N'%%' Or @PaymentMode = N'%'            
 	Insert Into @tmpPayMode Select PId From @TmpPayMode2
else              
 	Insert into @tmpPayMode Select PId From @TmpPayMode2 Where PayMode In(select * from dbo.sp_SplitIn2Rows(@PaymentMode, @Delimeter))

If @InvType = N'%' or @InvType = N'%%' or @InvType = N'All Invoices'
Begin
	Insert Into @TmpInvType Select 1
	Insert Into @TmpInvType Select 3
	Insert Into @TmpInvType Select 4
End
Else If @InvType = N'Sales Invoices'
Begin
	Insert Into @TmpInvType Select 1
	Insert Into @TmpInvType Select 3
End
Else
	Insert Into @TmpInvType Select 4


Insert Into @Invoice  
Select InvoiceID From InvoiceAbstract Where 
dbo.StripDateFromTime(InvoiceDate) Between @FromDate And @ToDate And
IsNull(Status,0) & 192 =0 And    
PaymentMode In (Select PayMode From @tmpPayMode) And 
CustomerID In (Select CustID From @tmpCus) And
DocSerialType like @DocType And 
InvoiceType In (Select InvType From @tmpInvType) 
Return  
End  

