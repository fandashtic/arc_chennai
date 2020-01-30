CREATE PROCEDURE sp_get_Payment_Alert(@Vendor nvarchar(15),    
      @FROM DATETIME,    
      @TO DATETIME)    
AS    
Create Table #temp(    
VendorID nvarchar(20) Null,    
DocCount Int Null,    
Balance Decimal(18,6) Null)    
    
Insert #temp  (VendorID, DocCount, Balance)    
SELECT BillAbstract.VendorID, Count(*), Sum(Balance)     
FROM BillAbstract    
WHERE BillAbstract.VendorID LIKE @Vendor AND    
Balance <> 0 AND    
BillAbstract.BillDate BETWEEN @FROM AND @TO AND    
(BillAbstract.Status & 128) = 0    
GROUP BY BillAbstract.VendorID    
    
Insert #temp (VendorID, DocCount, Balance)    
Select CreditNote.VendorID, Count(*), Sum(CreditNote.Balance)    
From CreditNote    
Where CreditNote.VendorID Like @Vendor And    
CreditNote.DocumentDate Between @From And @To And    
CreditNote.Balance > 0 And    
CreditNote.VendorID Is Not Null    
Group By CreditNote.VendorID    
    
Insert #temp  (VendorID, DocCount, Balance)    
Select DebitNote.VendorID, Count(*), 0 - Sum(DebitNote.Balance)    
From DebitNote    
Where DebitNote.VendorID Like @Vendor And    
DebitNote.VendorID Is Not Null And    
DebitNote.DocumentDate Between @From And @To And    
DebitNote.Balance > 0    
Group By DebitNote.VendorID    
    
Insert #temp (VendorID, DocCount, Balance)    
Select Payments.VendorID, Count(*),0 - Sum(Payments.Balance)    
From Payments    
Where Payments.VendorID Like @Vendor And    
Payments.DocumentDate Between @From And @To And    
Payments.Balance > 0 And    
IsNull(Payments.Status, 0) & 128 = 0    
Group By Payments.VendorID    
    
Insert #temp (VendorID, DocCount, Balance)    
select AdjustmentReturnAbstract.VendorID, count(*), 0 - Sum(AdjustmentReturnAbstract.Balance)
from AdjustmentReturnAbstract
where AdjustmentReturnAbstract.Balance > 0 and
AdjustmentReturnAbstract.AdjustmentDate Between @From And @To And    
AdjustmentReturnAbstract.VendorID like @Vendor and
(IsNull(AdjustmentReturnAbstract.Status, 0) & 192) = 0 
Group By AdjustmentReturnAbstract.VendorID    

Insert #temp (VendorID, DocCount, Balance)    
select ClaimsNote.VendorID, count(*), 0 - Sum(ClaimsNote.Balance)
From ClaimsNote
Where IsNull(Balance, 0) > 0 And
ClaimsNote.ClaimDate Between @From And @To And VendorID like @Vendor
Group by ClaimsNote.VendorID

Select Vendors.Vendor_Name, #temp.VendorID, Sum(DocCount), Sum(Balance)    
From #temp, Vendors    
Where #temp.VendorID collate SQL_Latin1_General_Cp1_CI_AS = Vendors.VendorID    
Group By #temp.VendorID, Vendors.Vendor_Name    
Drop Table #temp    
  

