Create Procedure Spr_list_Itemwise_Damaged_Return_Details(      
     @ITEMCODE nVarchar(50),      
     @SALESRETURNTYPE nVarchar(50),      
     @FROMDATE DATETIME,      
     @TODATE DATETIME      
)      
As      
Begin
Create table #tmpSalesReturn(CustomerID nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,       
    Type nVarChar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,       
    InvoiceID  nVarChar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,  
       DocumentNo nVarChar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,       
       DocRef nVarChar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,       
       ItemCode nVarChar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,       
       Quantity Decimal(18,6),       
       Amount Decimal(18,6),       
       BeatName nVarChar(510)  COLLATE SQL_Latin1_General_CP1_CI_AS,       
       CustomerName nVarChar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS)      
      
Create table #tmpBeat_Customer(CustomerID nVarchar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,       
        BeatID Integer,       
        BeatName nVarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS)            
      
Create table #tmpItemWiseSR( ID Int Identity(1,1),       
       BeatName nVarChar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,       
       CustomerID nVarchar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,       
       CustomerName nVarChar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,       
       SalesReturnVal Decimal(18,6),       
       Quantity Decimal(18,6),       
       Type nVarChar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,       
       InvoiceID  nVarChar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,  
       InvoiceNo nVarChar(500)  COLLATE SQL_Latin1_General_CP1_CI_AS,       
       DocRef nVarChar(1020)  COLLATE SQL_Latin1_General_CP1_CI_AS,      
       AdjReference nVarChar(1020)  COLLATE SQL_Latin1_General_CP1_CI_AS)       
  
Create table #tmpAddRefInvoices (AddRefInvoice nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)  
      
Declare @INVOICEPREFIX As nVarchar(50)        
Select @INVOICEPREFIX = IsNull(Prefix,'') from VoucherPrefix Where TranID =N'INVOICE'        
      
Insert into       
 #tmpSalesReturn      
Select       
  	IAbs.CustomerId, Case When IsNull(IAbs.Status,0)=0 Then N'Saleable' Else N'Damages' End,
	Case When IsNull(IAbs.InvoiceID,0)= 0 Then '' Else @INVOICEPREFIX + Cast(IAbs.InvoiceID As nvarchar(50)) End as InvoiceNo,
  	Case  IsNULL(IAbs.GSTFlag ,0) When 0 Then 
  	Case When IsNull(IAbs.DocumentID,0)= 0 Then '' Else @INVOICEPREFIX + Cast(IAbs.DocumentID As nvarchar(50)) End 
  	Else IsNULL(IAbs.GSTFullDocID,'') End as DocumentNo,  
  	IsNull(IAbs.DocReference,'') As DocRef,       
  	IDet.Product_Code, Sum(IDet.Quantity), Sum(IDet.Amount), '' as Beat, '' as Customer        
From       
  InvoiceAbstract as IAbs, InvoiceDetail as IDet      
Where      
  IDet.Product_Code = @ITEMCODE      
 And IsNull(IAbs.Status, 0) & 32 =       
  (Case @SALESRETURNTYPE       
    When N'Saleable' Then 0      
    When N'Damages' Then 32       
    Else IsNull(IAbs.Status, 0) & 32  End)       
 And IAbs.InvoiceType in (4,5)       
 And IAbs.InvoiceDate BETWEEN @FROMDATE AND @TODATE       
 And IsNull(IAbs.Status, 0) & 192 = 0      
 And IAbs.InvoiceID  = IDet.InvoiceID      
Group By       
	IAbs.CustomerId, IAbs.Status, IAbs.InvoiceID, IAbs.DocumentID, IAbs.DocReference, IDet.Product_Code,IAbs.GSTFlag,IAbs.GSTFullDocID      
      
Insert into #tmpBeat_Customer       
Select  Beat_SalesMan.CustomerID, Beat.BeatID, Beat.Description      
From  Beat_SalesMan
Left Outer Join Beat  On Beat.BeatID = Beat_SalesMan.BeatID          
      
Update  tmpSR Set BeatName = tmpBC.BeatName       
From  #tmpSalesReturn as tmpSR, #tmpBeat_Customer as tmpBC      
Where  tmpBC.CustomerID = tmpSR.CustomerID      
      
Insert into #tmpItemWiseSR      
Select  tmpSR.BeatName, C.CustomerID, C.Company_Name, Sum(tmpSR.Amount) as Amt, Sum(tmpSR.Quantity) as Qty,  
 tmpSR.Type, tmpSR.InvoiceID, '' as DocumentNo, '' as DocRef, '' as AdjReference       
From  #tmpSalesReturn tmpSR, Customer C      
Where  C.CustomerID = tmpSR.CustomerID      
Group By tmpSR.BeatName, C.CustomerID, C.Company_Name, tmpSR.InvoiceID, tmpSR.Type      
      
  
Declare @TOTREC As Int       
Declare @CNT As Int      
Declare @DOCUMENTNO nVarChar(50)  
Declare @INVOICENO nVarChar(50)      
Declare @DOCREF nVarChar(50)      
Declare @INVOICENOGRP as nVarChar(500)      
Declare @DOCREFGRP as nVarChar(500)      
Declare @ADJREFINVOICES as nVarChar(550)      
Declare @TMPADJREF as nVarChar(50)   
Set @CNT = 1    
Select @TOTREC = Count(*) From #tmpItemWiseSR    
While @TOTREC >= @CNT     
 BEGIN    
  Set @INVOICENOGRP = ''    
    Set @DOCREFGRP = ''    
    set @ADJREFINVOICES = ''      
    DECLARE InvoiceNo_Cursor CURSOR FOR    
    Select  tmpSR.InvoiceID, tmpSR.DocRef, tmpSR.DocumentNo    
    From  #tmpSalesReturn as tmpSR, #tmpItemWiseSR as tmpItmSR    
    Where      
      tmpItmSR.ID = @CNT     
   And tmpSR.InvoiceID = tmpItmSR.InvoiceID    
      And tmpSR.BeatName = tmpItmSR.BeatName    
      And tmpSR.CustomerID = tmpItmSR.CustomerID     
      And tmpSR.Type = tmpItmSR.Type     
    OPEN InvoiceNo_Cursor    
    FETCH NEXT FROM InvoiceNo_Cursor INTO @INVOICENO, @DOCREF, @DOCUMENTNO    
    WHILE @@FETCH_STATUS = 0    
      BEGIN    
       Set @INVOICENOGRP = Case When Len(@INVOICENOGRP)= 0 Then @DOCUMENTNO Else @INVOICENOGRP + ', ' + @DOCUMENTNO End    
       Set @DOCREFGRP = Case When Len(@DOCREFGRP)= 0 Then @DOCREF Else @DOCREFGRP + ', ' + @DOCREF End    
       Set @ADJREFINVOICES = Case     
        When Len(@ADJREFINVOICES)= 0 Then dbo.GetSalesReturnReference(Replace(@INVOICENO,@INVOICEPREFIX,''))     
          When (Len(@ADJREFINVOICES)> 0 And LEN(dbo.GetSalesReturnReference(Replace(@INVOICENO,@INVOICEPREFIX,'')))= 0) Then @ADJREFINVOICES + ''    
          Else  
            (@ADJREFINVOICES + ' ,' + dbo.GetSalesReturnReference(Replace(@INVOICENO,@INVOICEPREFIX,'')))     
          End           
      FETCH NEXT FROM InvoiceNo_Cursor INTO @INVOICENO, @DOCREF, @DOCUMENTNO    
     END    
    CLOSE InvoiceNo_Cursor       
    DEALLOCATE InvoiceNo_Cursor      
--To Get the Distinct Add Ref number   
    DELETE FROM #tmpAddRefInvoices  
    Insert into #tmpAddRefInvoices Select * from dbo.sp_SplitIn2Rows(@ADJREFINVOICES, ',')  
    SET @ADJREFINVOICES = ''  
    SET @TMPADJREF = ''       
    DECLARE InvoiceNo_Cursor CURSOR FOR  
    SELECT DISTINCT LTRIM(RTRIM(AddRefInvoice)) From #tmpAddRefInvoices  
    OPEN InvoiceNo_Cursor  
    FETCH NEXT FROM InvoiceNo_Cursor INTO @TMPADJREF  
    WHILE @@FETCH_STATUS = 0  
      BEGIN  
    SET @ADJREFINVOICES = Case When Len(@ADJREFINVOICES) = 0 Then @TMPADJREF Else @ADJREFINVOICES + ' ,' + @TMPADJREF  End  
    FETCH NEXT FROM InvoiceNo_Cursor INTO @TMPADJREF  
      END  
  CLOSE InvoiceNo_Cursor  
     DEALLOCATE InvoiceNo_Cursor  
  
    Update #tmpItemWiseSR Set InvoiceNo = @INVOICENOGRP, DocRef = @DOCREFGRP, AdjReference= @ADJREFINVOICES Where ID = @CNT       
    SET @CNT = @CNT + 1      
  END  
      
Select  "Beat" = BeatName, "Beat Name" = BeatName, "Customer Name" = CustomerName, "Sales Return value (%c)"=SalesReturnVal,      
  Quantity, Type, "Sales Return Invoice Nos." = InvoiceNo, "Doc Ref"=DocRef, "Adjusted Reference" = AdjReference      
From  #tmpItemWiseSR Order By BeatName, CustomerName  
  
Drop Table #tmpSalesReturn      
Drop table #tmpBeat_Customer      
Drop table #tmpItemWiseSR      
Drop table #tmpAddRefInvoices    
End
