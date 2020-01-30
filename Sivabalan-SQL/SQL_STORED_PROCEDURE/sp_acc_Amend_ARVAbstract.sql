CREATE Procedure sp_acc_Amend_ARVAbstract(@ARVDate datetime,  
        @PartyAccountID Int,  
        @Value Float,  
        @ARVemarks nvarchar(4000),  
        @ApprovedBy integer,  
        @DocRef nVarchar(255),  
        @TotalSalesTax Float,  
      @DocSerialType nvarchar(100),  
      @RefDocID Integer,  
      @IsNew Integer = 0)  
As  
Declare @DocID nvarchar(50)  
Declare @DetailType Integer  
Declare @Particular nvarchar(4000)  
Declare @ASSET Int  
Declare @OTHERS Int  
Declare @CREDITCARD Int  
Declare @COUPON Int  
Declare @COLUMN_SEP nvarchar(4000)  
Declare @RECORD_SEP nvarchar(4000)  
Declare @FirstSplitRecords nvarchar(4000)  
Declare @BatchCode Int  
Declare @ContraSerial INT  
  
Set @ASSET = 0  
Set @OTHERS = 1  
Set @CREDITCARD = 3  
Set @COUPON = 4   
Set @COLUMN_SEP = Char(1)  
Set @RECORD_SEP = Char(2)  
  
Create Table #TempFirstSplit(FirstSplitRecords nvarchar(4000))      
Create Table #TempSecondSplit(SecondSplitRecords nvarchar(4000), DocID INT IDENTITY(1,1))  
--Update ARVAbstact Table First---  
Update ARVAbstract Set Status = (isnull(Status,0) | 128) where Documentid = @RefDocID  
--Update ARVDetails  
Declare ScanDetail Cursor Dynamic for  
Select Type,Particular from ARVDetail where DocumentID = @RefDocID  
Open ScanDetail  
Fetch From ScanDetail Into @DetailType,@Particular  
While @@Fetch_Status = 0  
 Begin  
  If @DetailType <> @OTHERS  
   Begin  
    Insert #TempFirstSplit      
    Exec Sp_acc_SQLSplit @Particular,@RECORD_SEP  
    Declare ScanRecords Cursor Dynamic for  
    Select FirstSplitRecords from #TempFirstSplit  
    Open ScanRecords  
    Fetch from ScanRecords Into @FirstSplitRecords  
    While @@Fetch_Status = 0  
     Begin  
      Insert #TempSecondSplit  
      Exec Sp_acc_SQLSplit @FirstSplitRecords,@COLUMN_SEP  
  Select Top 1 @BatchCode = SecondSplitRecords from #TempSecondSplit  
      If @DetailType = @ASSET  
       Begin  
        Exec sp_acc_updateARVbatchassets @BatchCode,1  
       End  
      Else If @DetailType = @CREDITCARD Or @DetailType = @COUPON  
       Begin  
        If @IsNew = 1 /*New Implementation?*/  
         Begin  
          /*New Implementation of ARV using ListView. Update Collections If Type is   
          CreditCard else Update Coupon. Update ContraDetail in both cases.*/  
          Select @ContraSerial = SecondSplitRecords from #TempSecondSplit Where DocID = 9 /*ContraSerialCode*/  
          Exec sp_acc_UpdateARVContraDetailNew @ContraSerial, 0, @DetailType, @BatchCode, 0  
         End  
        Else  
         Exec sp_acc_updateARVContraDetail @BatchCode,0  
       End  
      Truncate Table #TempSecondSplit     
      Fetch Next From ScanRecords Into @FirstSplitRecords  
     End  
    Close ScanRecords  
    DeAllocate ScanRecords  
   End  
  Truncate Table #TempFirstSplit  
  Fetch Next From ScanDetail Into @DetailType,@Particular  
 End  
Close ScanDetail  
DeAllocate ScanDetail  
Drop Table #TempFirstSplit  
Drop Table #TempSecondSplit  
  
Select @DocID = ARVID from ARVAbstract Where DocumentID = @RefDocID  
If @DocID = ''  
 Begin   
  Begin Tran  
   select @DocID = DocumentID from DocumentNumbers where Doctype = 54  
   update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 54  
  Commit Tran  
 End  
  
Insert into ARVAbstract(ARVID,  
   ARVDate,  
   PartyAccountID,  
   Amount,  
   ARVRemarks,  
   ApprovedBy,  
   Balance,  
   DocRef,  
   TotalSalesTax,  
   CreationTime,  
   DocSerialType,  
   RefDocID)  
values  
   (@DocID,  
   @ARVDate,  
   @PartyAccountID,  
   @Value,  
   @ARVemarks,  
   @ApprovedBy,  
   @Value,  
   @DocRef,  
   @TotalSalesTax,  
   getdate(),  
   @DocSerialType,  
   @RefDocID)  
Set @DocID=dbo.getvoucherprefix(N'ACCOUNTS RECEIVABLE VOUCHER') + @DocID  
Select @@IDENTITY, @DocID 
