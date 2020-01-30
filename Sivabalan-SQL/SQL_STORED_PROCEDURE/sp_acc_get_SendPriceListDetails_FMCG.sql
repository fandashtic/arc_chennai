CREATE Procedure sp_acc_get_SendPriceListDetails_FMCG (@DetailsReqd INT,@Existing INT,@DocumentID INT,@SendPriceListDate DateTime=NULL)  
As  
SET DATEFORMAT DMY  
/*@DetailsReqd = 1 - Customer / Branch Details  
  @DetailsReqd = 2 - Itemdetails  
  
  If @Existing = 1 then get the details from already Sent Price List Table  
  If @Existing = 0 then Get the details from PriceList tables  
  If @Existing = 0 then @DocumentID refers to PriceListID*/  
If @DetailsReqd=0  
 Begin  
  /*No @Existing=0 mode coz, the Price List descirirtion hAs to be keyed in by the user*/  
  If @Existing=1  
   Begin  
    Select PL.PriceListName As PriceListName,SPL.PriceListID As PriceListID from PriceList PL, SendPriceList SPL  
    Where PL.PriceListID=SPL.PriceListID And SPL.DocumentID=@DocumentID  
   End  
 End  
Else If @DetailsReqd=1  
 Begin  
  If @Existing=0   
   Begin  
    If (Select PriceListFor from PriceList Where PriceListID=@DocumentID)=0  
     Begin  
      Select PLB.BranchID,C.Company_Name As Branch_Name from   
      PriceListBranch PLB,Customer C Where PLB.BranchID = C.CustomerID  
      And PLB.PriceListID = @DocumentID  
     End  
    Else  
     Begin  
      Select PLB.BranchID,W.Warehouse_Name As Branch_Name from   
      PriceListBranch PLB,Warehouse W Where PLB.BranchID = W.WarehouseID  
      And PLB.PriceListID = @DocumentID  
     End  
   End  
  Else If @Existing=1   
   Begin  
    If (Select PriceListFor from SendPriceList Where DocumentID=@DocumentID)=0  
     Begin  
      Select SPLB.BranchID,C.Company_Name As Branch_Name from   
      SendPriceListBranch SPLB,Customer C Where SPLB.BranchID = C.CustomerID  
      And SPLB.DocumentID = @DocumentID  
     End  
    Else  
     Begin  
      Select SPLB.BranchID,W.Warehouse_Name As Branch_Name from   
      SendPriceListBranch SPLB,Warehouse W Where SPLB.BranchID = W.WarehouseID  
      And SPLB.DocumentID = @DocumentID  
     End  
   End  
 End  
Else If @DetailsReqd=2  
 Begin  
  If @Existing=0   
   Begin  
    Declare @MaxPriceListDate DateTime  
    Declare @PriceListCnt INT  
    Declare @Cust_BR INT  
      
    Select @Cust_BR=PriceListFor from PriceList Where PriceListID=@DocumentID  
      
    Select @MaxPriceListDate=IsNULL(Max(PriceListDate),@SendPriceListDate) from SendPriceList  
    Where PriceListId=@DocumentID And PriceListDate<=@SendPriceListDate And PriceListFor=@Cust_BR  
      
    Select @PriceListCnt=COUNT(1) from SendPriceList Where PriceListDate=@MaxPriceListDate And PriceListFor=@Cust_BR And PriceListID=@DocumentID  
      
    CREATE TABLE #ItemDetails  
    (Row_Num INT IDENTITY,Product_Code nVarChar(50),ProductName nVarChar(255),  
    PTS Decimal(18,6),PTR Decimal(18,6),ECP Decimal(18,6),  
    Purchase_Price Decimal(18,6),Sale_Price Decimal(18,6),MRP Decimal(18,6),  
    Company_Price Decimal(18,6),Tax_Suffered nVarChar(255),Tax_Applicable nVarChar(255))  
      
    If @PriceListCnt>0   
     Begin  
      Declare @ItemCode nVarChar(50)  
      /* Process:  
      1.Get the ItemCodes available in PriceListItem bAsis the PricelistID  
      2.Create a Cursor on the Above  
      3.Check If any entry available in SendPriceListItem for the Particular Item code   
        And for a Particular Customer / Branch  
      4.If available Get the TOP row.  
      5.If not available get the details from Item MAster  
      This is applicable only for New Price List sending .For existing get the details   
      from the Send Price List Item Table */  
      DECLARE Items CURSOR FOR  
      Select Product_Code from PriceListItem Where PriceListID=@DocumentID  
      OPEN Items  
      FETCH FROM Items Into @ItemCode  
      WHILE @@FETCH_STATUS = 0  
       Begin  
        If (Select COUNT(1) from SendPriceListItem Where Product_Code=@ItemCode   
            And DocumentID IN (Select DocumentID from SendPriceList Where   
            PriceListFor=@Cust_BR And PriceListDate=@MaxPriceListDate))> 0  
         Begin  
          Insert Into #ItemDetails   
          (Product_Code,PTS,PTR,ECP,Purchase_Price,Sale_Price,MRP,  
          Company_Price,Tax_Suffered,Tax_Applicable,ProductName)  
          Select Top 1 SPL.Product_Code,SPL.PTS,SPL.PTR,SPL.ECP,  
          SPL.PurchasePrice,SPL.SellingPrice,SPL.MRP,SPL.SpecialPrice,  
          IsNULL((Select Tax_Description from Tax Where Tax_Code IN  
          (Select TaxSuffered from PriceListItem Where PriceListId=@DocumentID And Product_Code=@ItemCode)),''),  
          IsNULL((Select Tax_Description from Tax Where Tax_Code IN  
          (Select TaxApplicable from PriceListItem Where PriceListId=@DocumentID And Product_Code=@ItemCode)),''),  
          I.ProductName from SendPriceListItem SPL,Items I  
          Where DocumentID IN (Select DocumentID from SendPriceList Where PriceListFor=@Cust_BR)  
          And SPL.Product_Code=@ItemCode And SPL.Product_Code=I.Product_Code  
          Order by DocumentID Desc  
         End  
        Else  
         Begin  
          Insert Into #ItemDetails  
          (Product_Code,PTS,PTR,ECP,Purchase_Price,Sale_Price,MRP,  
          Company_Price,Tax_Suffered,Tax_Applicable,ProductName)  
          Select PLI.Product_Code,0,0,0,I.Purchase_Price,I.Sale_Price,I.MRP,0,  
          IsNULL((Select Tax_Description from Tax Where Tax_Code=PLI.TaxSuffered),'') As "Tax_Suffered",  
          IsNULL((Select Tax_Description from Tax Where Tax_Code = PLI.TaxApplicable),'') As "Tax_Applicable",  
          I.ProductName From PriceListItem PLI,Items I  
          Where PLI.PriceListID=@DocumentID And PLI.Product_Code=@ItemCode  
          And PLI.Product_Code=I.Product_Code  
         End  
        FETCH NEXT FROM Items Into @ItemCode  
       End  
          
      Select Product_Code,ProductName,PTS,PTR,ECP,Purchase_Price,Sale_Price,MRP,Company_Price   
      As "Special_Price",Tax_Suffered,Tax_Applicable from #ItemDetails Order By Row_Num  
      CLOSE Items                  
      DEALLOCATE Items  
     End  
    Else  
     Begin  
      Insert Into #ItemDetails  
      (Product_Code,PTS,PTR,ECP,Purchase_Price,Sale_Price,MRP,  
      Company_Price,Tax_Suffered,Tax_Applicable,ProductName)  
      Select PLI.Product_Code,0,0,0,I.Purchase_Price,I.Sale_Price,I.MRP,0,  
      IsNULL((Select Tax_Description from Tax Where Tax_Code=PLI.TaxSuffered),'') As "Tax_Suffered",  
      IsNULL((Select Tax_Description from Tax Where Tax_Code=PLI.TaxApplicable),'') As "Tax_Applicable",  
      I.ProductName From PriceListItem PLI,Items I  
      Where PLI.PriceListID=@DocumentID And PLI.Product_Code=I.Product_Code  
        
      Select Product_Code,ProductName,PTS,PTR,ECP,Purchase_Price,Sale_Price,MRP,Company_Price  
      As "Special_Price",Tax_Suffered,Tax_Applicable from #ItemDetails Order By Row_Num  
     End  
    Drop Table #ItemDetails  
   End  
  Else If @Existing=1  
   Begin  
    Select I.ProductName,SPLI.Product_Code,SPLI.PTS,SPLI.PTR,SPLI.ECP,  
    SPLI.PurchasePrice As "Purchase_Price",SPLI.SellingPrice As "Sale_Price",   
    SPLI.MRP,SPLI.SpecialPrice As "Special_Price",IsNULL((Select Tax_Description from Tax   
    Where Tax_Code = SPLI.TaxSuffered),'') As "Tax_Suffered",IsNULL((Select Tax_Description from Tax   
    Where Tax_Code = SPLI.TaxApplicable),'') As "Tax_Applicable" From SendPriceListItem SPLI,Items I  
    Where SPLI.DocumentID=@DocumentID And SPLI.Product_Code=I.Product_Code  
   End  
 End  
