  
Create Procedure spr_DSWiseLoadingSlip_Detail_ITC ( @ProductCode nVarChar(30), @SalesmanID nVarChar(510), @Beat nVarChar(510),@FromDate DateTime, @ToDate DateTime,@DocPrefix nVarchar(20), @FromInvoice nVarChar(510), @ToInvoice nVarChar(510),@UOM nVarChar(20))      
As      
Begin      
    
Declare @Delimeter  Char(1)                
      
Set @Delimeter=Char(15)                          
Create Table #tmpBeat(BeatID Int)       
Create Table #tmpSalesman(SalesmanID Int)

If @SalesmanID = '%'       
 Insert into #tmpSalesman
        Select Distinct SalesmanID From Salesman
Else      
  Insert Into #tmpSalesman
            Select SalesmanId From Salesman Where Salesman_Name In ( Select * From Dbo.sp_SplitIn2Rows(@SalesmanID,@Delimeter))                          
   
If @Beat = '%'       
 Insert into #tmpBeat       
        Select Distinct BeatId From Beat      
Else      
  Insert Into #tmpBeat       
            Select BeatId From Beat Where Description In ( Select * From Dbo.sp_SplitIn2Rows(@Beat,@Delimeter))                          
    
    
IF @FromInvoice = '%' SET @FromInvoice = '0'        
IF @ToInvoice = '%' SET @ToInvoice = '2147483647'        
    
If @DocPrefix ='%'       
Begin      
 Select Distinct S.SalesMan_Name,"Salesman" = S.SalesMan_Name, "Beat Name" = B.Description      
 From SalesMan S,InvoiceAbstract Ia,      
 InvoiceDetail Idt, Beat B      
 Where Ia.InvoiceId = Idt.InvoiceId       
 And Ia.InvoiceType in (1,3, 4)
 And Ia.Status & 128 =0       
 And Ia.BeatId In (Select BeatId from #tmpBeat)      
 And Ia.SalesmanId In(Select SalesmanID From #tmpSalesman)
 And dbo.GetTrueVal(IA.DocReference) Between dbo.GetTrueVal(@FromInvoice) And dbo.GetTrueVal(@ToInvoice)      
 And Idt.Product_Code = @ProductCode      
 And S.SAlesManId = ia.SalesManId      
 And B.BeatId  = Ia.BeatId      
 And Ia.InvoiceDate Between @FromDate And @ToDate    
End      
Else      
Begin      
 Select Distinct S.SalesMan_Name,"Salesman" = S.SalesMan_Name, "Beat Name" = B.Description      
 From SalesMan S,InvoiceAbstract Ia,      
 InvoiceDetail Idt, Beat B      
 Where Ia.InvoiceId = Idt.InvoiceId       
 And Ia.InvoiceType in (1,3, 4)
 And Ia.Status & 128 =0       
 And dbo.GetTrueVal(IA.DocReference) Between dbo.GetTrueVal(@FromInvoice) And dbo.GetTrueVal(@ToInvoice)      
 And DocSerialType =  @DocPrefix      
 And Idt.Product_Code = @ProductCode      
 And S.SAlesManId = ia.SalesManId      
 And B.BeatId  = Ia.BeatId      
 And Ia.BeatId In (Select BeatId from #tmpBeat)      
 And Ia.SalesmanId In(Select SalesmanID From #tmpSalesman)
 And Ia.InvoiceDate Between @FromDate And @ToDate    
End      
End      
