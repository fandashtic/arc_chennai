CREATE Procedure sp_Save_DispatchAbstract
(
	@REFNUMBER nvarchar(255),    
	@DISPATCHDATE DATETIME ,     
	@CUSTOMERID NVARCHAR (15),     
	@BILLADDRESS NVARCHAR(255),    
	@SHIPADDRESS NVARCHAR(255),    
	@STATUS INT,     
	@NEWREFNUMBER nvarchar(255),    
	@MEMO1 nvarchar(256),    
	@MEMO2 nvarchar(256),    
	@MEMO3 nvarchar(256),  
	@DOCREF NVARCHAR(255)=NULL,
	@SalesmanID int = 0,
	@BeatID int = 0,
	@GroupID nVarchar(1000) = N'',
	@UserName Nvarchar(100) = Null
)    
AS    
DECLARE @DocumentID int    
DECLARE @MEMOLABEL1 nvarchar(255)    
DECLARE @MEMOLABEL2 nvarchar(255)    
DECLARE @MEMOLABEL3 nvarchar(255)    
    
SELECT @MEMOLABEL1 = MemoLabel4, @MEMOLABEL2 = MemoLabel5, @MEMOLABEL3 = MemoLabel6 FROM Setup    
BEGIN TRAN    
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 3    
SELECT @DocumentID = DocumentID-1 FROM DocumentNumbers WHERE DocType = 3    
COMMIT TRAN    
Insert into DispatchAbstract    
(
	RefNumber,    
	DispatchDate,    
	CustomerID,    
	BillingAddress,    
	ShippingAddress,    
	Status,     
	DocumentID,    
	NewRefNumber,    
	Memo1,    
	Memo2,    
	Memo3,    
	MemoLabel1,    
	MemoLabel2,    
	MemoLabel3,  
	DocRef,
	GroupID,
	SalesmanID,
	BeatID,
	UserName
)     
values 
(
	@REFNUMBER,    
	@DISPATCHDATE,     
	@CUSTOMERID,     
	@BILLADDRESS,    
	@SHIPADDRESS,    
	@STATUS,     
	@DocumentID,    
	@NewRefNumber,    
	@MEMO1,    
	@MEMO2,    
	@MEMO3,    
	@MEMOLABEL1,    
	@MEMOLABEL2,    
	@MEMOLABEL3,  
	@DOCREF,
	@GroupID,
	@SalesmanID,
	@BeatID,
	@UserName
)    
Select @@Identity, @DocumentID    

