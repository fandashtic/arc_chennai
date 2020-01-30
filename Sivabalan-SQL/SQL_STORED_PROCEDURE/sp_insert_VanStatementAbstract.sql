
CREATE PROCEDURE sp_insert_VanStatementAbstract (@DocumentDate datetime,  
         @SalesmanID int,  
         @BeatID int,  
         @DocumentValue Decimal(18,6),  
         @VanID nvarchar(50),   
         @LoadingDate DateTime,
		 @UserName nvarchar(50))  
as  

Declare @DocID int  
Declare @DocPrefix nvarchar(255)  
Select @DocPrefix = Prefix From VoucherPrefix Where TranID = 'VAN LOADING SLIP'  
Select @BeatID = IsNull(BeatID,0) From Beat_Salesman Where SalesmanID = @SalesmanID  

Begin Tran  
Update DocumentNumbers Set DocumentID =  DocumentID + 1 Where DocType = 14  
Select @DocID = DocumentID - 1 From DocumentNumbers Where DocType = 14  
Commit Tran  

Insert into VanStatementAbstract (DocumentID,  
          DocumentDate,  
          SalesmanID,  
          BeatID,  
          DocumentValue,  
          VanID,  
          Status,  
          LoadingDate,
		  UserName)  
Values (@DocID,  
		@DocumentDate,  
		@SalesmanID,  
		@BeatID,  
		@DocumentValue,  
		@VanID,  
		0,  
		@LoadingDate,
		@UserName)  
SELECT @@IDENTITY, @DocID  

